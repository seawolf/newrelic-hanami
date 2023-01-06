# frozen_string_literal: true

require 'hanami/router'
require 'hanami/controller'

require_relative './actions/simple'
require_relative './actions/with_callback'
require_relative './actions/with_callbacks'

module Nested; end
require_relative './actions/nested/simple'
require_relative './actions/nested/with_callback'
require_relative './actions/nested/with_callbacks'

module RSpec
  module HanamiApps
    APP_CONTROLLER_2 = Hanami::Router.new do
      get '/', to: ->(*) { [200, {}, ["Welcome to Hanami v#{Hanami::Router::VERSION} !"]] }

      get '/simple', to: Simple.new
      get '/with_callback', to: WithCallback.new
      get '/with_callbacks', to: WithCallbacks.new

      scope :nested do
        get '/simple', to: Nested::Simple.new
        get '/with_callback', to: Nested::WithCallback.new
        get '/with_callbacks', to: Nested::WithCallbacks.new
      end
    end
  end
end
