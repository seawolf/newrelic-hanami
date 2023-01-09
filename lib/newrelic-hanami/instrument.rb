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
        def call(params)
          trace_options = _trace_options(params, [:call])

          perform_action_with_newrelic_trace(**trace_options) do
            super
          end
        end

        protected

        def _run_before_callbacks(request, _response)
          segment_options = _segment_options([:before])

          in_segment(**segment_options) do
            super
          end if _run_before_callbacks?
        end

=begin
          # This doesn't work because:
          # 1. Hanami framework is loaded, and defines the classes
          # 2. This instrumentation is loaded, overriding the Hanami classes
          # 3. the application is loaded, with the endpoint's #handle overriding the instrumentation
          # It needs to add to the application, not add to the framework.

          def handle(*)
            segment_options = _segment_options([:handle])

            in_segment(**segment_options) do
              super
            end
          end
=end

        def _run_after_callbacks(request, _response)
          segment_options = _segment_options([:after])

          in_segment(**segment_options) do
            super
          end if _run_after_callbacks?
        end

        private

        TRANSACTION_NAME_JOINER = '/'

        def _trace_options(params, path_segments = [])
          name = path_segments.join(TRANSACTION_NAME_JOINER) if path_segments.any?

          {
            category: :controller,
            class_name: class_name,
            name: name,
            request: self,
            params: params.to_h
          }
        end

        def transaction_name
          [class_name, path_name].join(TRANSACTION_NAME_JOINER)
        end

        def class_name
          self.class.name.split('::').join(TRANSACTION_NAME_JOINER)
        end

        def in_segment(opts)
          begin
            segment = NewRelic::Agent::Tracer.start_segment(**opts)
            begin
              yield
            rescue => e
              NewRelic::Agent.notice_error(e)
              raise
            end
          ensure
            segment.finish if segment
          end
        end

        def _segment_options(path_segments)
          {
            name: path_segments.join(TRANSACTION_NAME_JOINER)
          }
        end

        def _run_before_callbacks?
          config.before_callbacks.send(:chain).any?
        end

        def _run_after_callbacks?
          config.after_callbacks.send(:chain).any?
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
    Hanami::Action.prepend(NewRelic::Agent::Instrumentation::Hanami)
  end
end
