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
            if self.class.before_callbacks.send(:chain).any?
              Segment.in(name: 'before') do
                super
              end
            else
              super
            end
          end

          def _run_after_callbacks(*)
            if self.class.after_callbacks.send(:chain).any?
              Segment.in(name: 'after') do
                super
              end
            else
              super
            end
          end
        end
      end
    end
  end
end
