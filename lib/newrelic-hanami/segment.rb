# frozen_string_literal: true

module NewRelic
  module Agent
    module Instrumentation
      module Hanami
        # Segment is a block of work in a Trace.
        module Segment
          class << self
            def in(name:)
              segment = ::NewRelic::Agent::Tracer.start_segment(name: new_segment_name(name))

              begin
                yield
              ensure
                segment&.finish
              end
            end

            private

            SEGMENT_JOINER = '/'

            def new_segment_name(suffix)
              root = current_transaction_name&.to_s

              [root, suffix].compact.join(SEGMENT_JOINER)
            end

            def current_transaction_name
              ::NewRelic::Agent::Tracer.current_transaction&.transaction_name
            end
          end
        end
      end
    end
  end
end
