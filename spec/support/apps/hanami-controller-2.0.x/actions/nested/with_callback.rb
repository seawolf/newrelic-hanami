# frozen_string_literal: true

# An example of an Action with one callback.
module Nested
  class WithCallback < Hanami::Action
    before :preparation

    def handle(*, res)
      res.body = 'This is an example of a nested action with one callback.'
    end

    private

    def preparation
      true
    end
  end
end
