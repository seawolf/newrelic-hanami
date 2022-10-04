# frozen_string_literal: true

require 'new_relic/agent/instrumentation'
require 'new_relic/agent/instrumentation/controller_instrumentation'

module NewRelic
  module Agent
    module Instrumentation
      module Hanami
        # Wraps every Hanami::Action in NewRelic tracing
        module ActionTransaction
          include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation

          # Ensures the request is separated from the Rack/Hanami::Router#call above.
          # Also allows before/handle/after segments to assume they are within a transaction.
          def call(params)
            trace_options = _trace_options(self, params)

            perform_action_with_newrelic_trace(**trace_options) do
              super
            end
          end

          private

          NAME_REGEX = /Controllers::/.freeze

          def _trace_options(request, params)
            {
              category: :controller,
              request: request,
              params: params.to_h
            }
          end

          def create_transaction_options(*)
            super.tap do |txn_options|
              txn_options[:transaction_name] =
                CorrectedTransactionName.from_class_and_method_name(txn_options[:transaction_name])
            end
          end

          # Converts a Transaction name
          # from the "Controller/{Namespace}::{Action}" format
          # into the "Controller/{namespace}/{action}" format
          module CorrectedTransactionName
            class << self
              def from_class_and_method_name(str)
                str.to_s.split('/').tap do |segments|
                  segments[-1] = method_name(segments[-1])
                end.join('/')
              end

              def method_name(str)
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
end
