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
          trace_options = _trace_options(params)

          perform_action_with_newrelic_trace(**trace_options) do
            super
          end
        end

        private

        TRANSACTION_NAME_JOINER = '/'

        def _trace_options(params)
          {
            category: :controller,
            class_name: class_name,
            name: path_segments.join(TRANSACTION_NAME_JOINER),
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

        def path_segments
          ['call']
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
