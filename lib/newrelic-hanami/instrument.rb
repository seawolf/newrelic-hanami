# frozen_string_literal: true

require 'newrelic-hanami/active_support_inflector'

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
            txn_options[:transaction_name] =
              CorrectedTransactionName.from_transaction_name(txn_options[:transaction_name])
          end
        end

        # Converts a Transaction name
        # from the "Controller/{Namespace}::{Action}" format
        # into the "Controller/{namespace}/{action}" format
        module CorrectedTransactionName
          class << self
            def from_transaction_name(str)
              str.to_s.split('/').tap do |segments|
                segments[-1] = action_name(segments[-1])
              end.join('/')
            end

            def action_name(str)
              str.sub(NAME_REGEX, '').split('::').map do |segment|
                ::NewRelic::Hanami::ActiveSupportInflector.underscore(segment)
              end.join('/')
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
