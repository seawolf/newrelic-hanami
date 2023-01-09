# frozen_string_literal: true

module NewRelic
  module Agent
    module Instrumentation
      TRANSACTION_NAME_JOINER = '/'

      # Logic for how a while Hanami::Action is traced in NewRelic as a Transaction
      module Transaction
        module_function

        def trace_options(klass, params, path_segments = [])
          name = path_segments.join(TRANSACTION_NAME_JOINER) if path_segments.any?

          {
            category: :controller,
            class_name: klass.name.split('::').join(TRANSACTION_NAME_JOINER),
            name: name,
            request: klass,
            params: params.to_h
          }
        end

        def class_name
          NewRelic::Agent::Transaction
            .tl_current
            &.transaction_name
            &.delete_suffix('/call')
        end
      end
    end
  end
end
