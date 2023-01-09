# frozen_string_literal: true

module NewRelic
  module Agent
    module Instrumentation
      # Logic for how parts of a Hanami::Action are traced in NewRelic as a Transaction Segment
      module Segment
        module_function

        def segment_options(path_segments)
          # place within the current Transaction
          path_segments.unshift Transaction.class_name

          {
            name: path_segments.compact.join(TRANSACTION_NAME_JOINER)
          }
        end

        def in_segment(opts)
          segment = NewRelic::Agent::Tracer.start_segment(**opts)
          begin
            yield
          rescue StandardError => e
            NewRelic::Agent.notice_error(e)
            raise
          end
        ensure
          segment&.finish
        end

        def before_callbacks?(action)
          if action.class.respond_to?(:before_callbacks)
            # deprecated support for Hanami v2.0 alpha/beta releases
            # see: https://github.com/hanami/controller/pull/394
            return action.class.before_callbacks.send(:chain).any?
          end

          action.class.config.before_callbacks.send(:chain).any?
        end

        def after_callbacks?(action)
          if action.class.respond_to?(:after_callbacks)
            # deprecated support for Hanami v2.0 alpha/beta releases
            # see: https://github.com/hanami/controller/pull/394
            return action.class.after_callbacks.send(:chain).any?
          end

          action.class.config.after_callbacks.send(:chain).any?
        end
      end
    end
  end
end
