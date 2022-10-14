# frozen_string_literal: true

module NewRelic
  module Agent
    module Instrumentation
      module Hanami
        # Wraps the `before` and `after` callbacks in a NewRelic Transaction segment
        # They will appear as part of the overall Transaction from `call`.
        module ActionCallbackSegments
          private

          def _run_before_callbacks(*)
            Segment.in(name: 'before') do
              super
            end
          end

          def _run_after_callbacks(*)
            Segment.in(name: 'after') do
              super
            end
          end
        end
      end
    end
  end
end
