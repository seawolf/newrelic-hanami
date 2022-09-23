# frozen_string_literal: true

module NewRelic
  module Agent
    module Instrumentation
      module Hanami
        # Wraps the `handle` code in a NewRelic Transaction segment.
        # It will appear as part of the overall Transaction from `call`.
        module ActionHandleSegment
          def handle(request, response)
            Segment.in(name: 'handle') do
              super
            end
          end
        end
      end
    end
  end
end
