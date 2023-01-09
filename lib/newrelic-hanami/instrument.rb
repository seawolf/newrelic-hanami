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

        # Add one segment per Hanami::Action to cover the `handle` method,
        # as with the `before`/`after` callbacks within the `call` transaction.
        # Applications inherit from / override Hanami::Action#handle without
        # calling `super`, so any modifications to the `handle` definition will
        # not take effect. Instrumentation must be added after application code
        # is defined, achieved with a post-inheritence hook.
        module Handle
          def inherited(action_class)
            super

            action_class.prepend(Instrumentation)
          end

          # The real instrumentation of the `handle` methods.
          module Instrumentation
            def handle(request, response)
              segment_options = Segment.segment_options([:handle])

              Segment.in_segment(**segment_options) do
                super(request, response)
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
    defined?(Hanami) &&
      !NewRelic::Control.instance['disable_hanami'] &&
      !ENV['DISABLE_NEW_RELIC_HANAMI']
  end

  executes do
    NewRelic::Agent.logger.info 'Installing Hanami instrumentation: Call'
    Hanami::Action.prepend(NewRelic::Agent::Instrumentation::Hanami::Call)
  end

  executes do
    NewRelic::Agent.logger.info 'Installing Hanami instrumentation: Callbacks'
    Hanami::Action.prepend(NewRelic::Agent::Instrumentation::Hanami::Callbacks)
  end

  executes do
    NewRelic::Agent.logger.info 'Installing Hanami instrumentation: Handle'
    Hanami::Action.extend(NewRelic::Agent::Instrumentation::Hanami::Handle)
  end

  executes do
    ObjectSpace.each_object(Hanami::Action.singleton_class).each do |child|
      next if child == Hanami::Action

      NewRelic::Agent.logger.info "Installing Hanami instrumentation: #{child.name}#handle"
      child.prepend(NewRelic::Agent::Instrumentation::Hanami::Handle::Instrumentation)
    end
  end
end
