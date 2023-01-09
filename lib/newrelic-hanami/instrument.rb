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
        # Create the Transaction for the entire Hanami::Action#call method, to
        # later include `before`, `handle`, and `after` segments.
        module Call
          include ControllerInstrumentation

          def call(params)
            trace_options = Transaction.trace_options(self.class, params, [:call])

            perform_action_with_newrelic_trace(**trace_options) do
              super
            end
          end
        end

        # Add one segment per Hanami::Action to cover all the `before` and one
        # to cover all the `after` callbacks.
        module Callbacks
          protected

          def _run_before_callbacks(request, _response)
            segment_options = Segment.segment_options([:before])

            return super unless Segment.before_callbacks?(self)

            Segment.in_segment(**segment_options) do
              super
            end
          end

          def _run_after_callbacks(request, _response)
            segment_options = Segment.segment_options([:after])

            return super unless Segment.after_callbacks?(self)

            Segment.in_segment(**segment_options) do
              super
            end
          end
        end

        module Handle
          # This doesn't work because:
          # 1. Hanami framework is loaded, and defines the classes
          # 2. This instrumentation is loaded, overriding the Hanami classes
          # 3. the application is loaded, with the endpoint's #handle overriding the instrumentation
          # It needs to add to the application, not add to the framework.

          def handle(*)
            segment_options = _segment_options([:handle])

            Segment.in_segment(**segment_options) do
              super
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
    defined?(Hanami) &&
      !NewRelic::Control.instance['disable_hanami'] &&
      !ENV['DISABLE_NEW_RELIC_HANAMI']
  end

  executes do
    NewRelic::Agent.logger.info 'Installing Hanami instrumentation'
  end

  executes do
    Hanami::Action.prepend(NewRelic::Agent::Instrumentation::Hanami::Call)
    Hanami::Action.prepend(NewRelic::Agent::Instrumentation::Hanami::Callbacks)
    Hanami::Action.extend(NewRelic::Agent::Instrumentation::Hanami::Handle)
  end
end
