# frozen_string_literal: true

require 'hanami/controller'
require 'rack'

require 'new_relic/agent/instrumentation'
require 'new_relic/agent/instrumentation/controller_instrumentation'

require 'newrelic-hanami/version'
require 'newrelic-hanami/instrumentation'
