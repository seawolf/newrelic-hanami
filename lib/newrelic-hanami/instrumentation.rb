# frozen_string_literal: true

require 'newrelic-hanami/consistent_naming'
require 'newrelic-hanami/segment'

require 'newrelic-hanami/instrumentation/action_transaction'
require 'newrelic-hanami/instrumentation/action_handle_segment'
require 'newrelic-hanami/instrumentation/action_callback_segments'

DependencyDetection.defer do
  @name = :hanami

  depends_on do
    defined?(::Hanami) &&
      !::NewRelic::Control.instance['disable_hanami'] &&
      !ENV['DISABLE_NEW_RELIC_HANAMI']
  end

  executes do
    NewRelic::Agent.logger.info 'Installing Hanami::Action#handle instrumentation'

    NewRelic::Agent::Instrumentation::Hanami::ActionHandleSegmentInstaller = Module.new do
      def self.inherited(subclass)
        subclass.prepend(::NewRelic::Agent::Instrumentation::Hanami::ActionHandleSegment)

        super
      end
    end

    Hanami::Action.extend(NewRelic::Agent::Instrumentation::Hanami::ActionHandleSegmentInstaller)
  end

  executes do
    NewRelic::Agent.logger.info 'Installing Hanami::Action.call instrumentation'
    Hanami::Action.prepend(::NewRelic::Agent::Instrumentation::Hanami::ActionTransaction)
  end

  executes do
    NewRelic::Agent.logger.info 'Installing Hanami::Action callbacks instrumentation'
    Hanami::Action.prepend(::NewRelic::Agent::Instrumentation::Hanami::ActionCallbackSegments)
  end
end
