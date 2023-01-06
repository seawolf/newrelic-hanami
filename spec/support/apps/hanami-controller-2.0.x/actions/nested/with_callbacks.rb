# frozen_string_literal: true

# An example of an Action with Before and After callbacks.
module Nested
  class WithCallbacks < Hanami::Action
    before :preparation
    after  :cleanup

    def handle(*, res)
      res.body = 'This is an example of a nested action with Before and After callbacks.'
    end

    private

    def preparation
      true
    end

    def cleanup
      true
    end
  end
end
