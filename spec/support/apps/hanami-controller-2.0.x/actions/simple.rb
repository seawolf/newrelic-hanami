# frozen_string_literal: true

# An example of an Action.
class Simple < Hanami::Action
  def handle(*, res)
    res.body = 'This is a very simple example.'
  end
end
