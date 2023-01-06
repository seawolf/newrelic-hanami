# frozen_string_literal: true

# An example of an Action.
module Nested
  class Simple < Hanami::Action
    def handle(*, res)
      res.body = 'This is a simple, but nested, example.'
    end
  end
end
