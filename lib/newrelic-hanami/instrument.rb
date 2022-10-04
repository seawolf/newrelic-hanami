# frozen_string_literal: true

require 'new_relic/agent/instrumentation'
require 'new_relic/agent/instrumentation/controller_instrumentation'
require 'hanami/controller'
require 'rack'

module NewRelic
  module Agent
    module Instrumentation
      # Wraps every Hanami::Action in NewRelic tracing
      module Hanami
        include ControllerInstrumentation
        NAME_REGEX = /Controllers::/.freeze

        def call(params)
          trace_options = _trace_options(params)

          perform_action_with_newrelic_trace(**trace_options) do
            super
          end
        end

        private

        def _trace_options(params)
          {
            category: :controller,
            request: self,
            params: params.to_h
          }
        end

        def create_transaction_options(*)
          super.tap do |txn_options|
            txn_options[:transaction_name] = CorrectedTransactionName.from_transaction_name(txn_options[:transaction_name])
          end
        end

        module CorrectedTransactionName
          class << self
            def from_transaction_name(str)
              str.to_s.split('/').tap do |segments|
                segments[-1] = action_name(segments[-1])
              end.join('/')
            end

            def action_name(str)
              str.sub(NAME_REGEX, '').split('::').map { ActiveSupportInflector.underscore(_1) }.join('/')
            end

            # Copy of Rails' `underscore` method from ActiveSupport::Inflector
            # https://github.com/rails/rails/blob/v7.0.4/activesupport/lib/active_support/inflector/inflections.rb
            module ActiveSupportInflector
              ACRONYMS                  = {}
              ACRONYM_REGEX             = ACRONYMS.empty? ? /(?=a)b/ : /#{ACRONYMS.values.join("|")}/
              ACRONYMS_UNDERSCORE_REGEX = /(?:(?<=([A-Za-z\d]))|\b)(#{ACRONYM_REGEX})(?=\b|[^a-z])/

              class << self
                def underscore(camel_cased_word)
                  return camel_cased_word unless /[A-Z-]|::/.match?(camel_cased_word)

                  word = camel_cased_word.to_s.gsub('::', '/')
                  word.gsub!(ACRONYMS_UNDERSCORE_REGEX) { "#{$1 && '_'.freeze }#{$2.downcase}" }
                  word.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
                  word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
                  word.tr!('-', '_')
                  word.downcase!

                  word
                end
              end
            end
          end
        end
      end
    end
  end
end

DependencyDetection.defer do
  @name = :hanami

  depends_on do
    defined?(::Hanami) &&
      !::NewRelic::Control.instance['disable_hanami'] &&
      !ENV['DISABLE_NEW_RELIC_HANAMI']
  end

  executes do
    NewRelic::Agent.logger.info 'Installing Hanami instrumentation'
  end

  executes do
    Hanami::Action.prepend(::NewRelic::Agent::Instrumentation::Hanami)
  end
end
