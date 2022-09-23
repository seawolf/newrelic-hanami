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

          def _trace_options(request, params)
            {
              category: :controller,
              request: request,
              params: params.to_h
            }
          end
        end
      end
    end
  end
end
