# frozen_string_literal: true

describe NewRelic::Agent::Instrumentation::Hanami::ActionCallbackSegments do
  let(:instance) { klass.new }

  before do
    stub_const klass.name, klass
  end

  let(:request_params) { {} }
  let(:response)       { instance.call(request_params) }

  let(:transaction) do
    # built by Instrumentation::Hanami::Action
    instance_double(::NewRelic::Agent::Transaction, transaction_name: transaction_name).as_null_object
  end

  before do
    allow(::NewRelic::Agent::Tracer).to receive(:current_transaction).and_return(transaction)
  end

  shared_examples 'a Hanami::Action with callbacks' do
    let(:call_segment)   { instance_double(::NewRelic::Agent::Transaction::Segment).as_null_object }
    let(:before_segment) { instance_double(::NewRelic::Agent::Transaction::Segment).as_null_object }
    let(:handle_segment) { instance_double(::NewRelic::Agent::Transaction::Segment).as_null_object }
    let(:after_segment)  { instance_double(::NewRelic::Agent::Transaction::Segment).as_null_object }

    it 'traces the `before` and `after` callbacks with amended options (corrected name, etc.)' do
      expect(::NewRelic::Agent::Transaction::Segment).to receive(:new)
        .with("#{transaction_name}/before", anything, anything).ordered.once
        .and_return(before_segment)

      expect(before_segment).to receive(:start).ordered.once
      expect(before_segment).to receive(:finish).ordered.once

      expect(::NewRelic::Agent::Transaction::Segment).to receive(:new)
        .with("#{transaction_name}/after", anything, anything).ordered.once
        .and_return(after_segment)

      expect(after_segment).to receive(:start).ordered.once
      expect(after_segment).to receive(:finish).ordered.once

      expect(transaction).to receive(:finish).ordered.once

      response
    end
  end

  context 'with a top-level action class' do
    let(:transaction_name) { 'Controller/web/customers_database/index' }

    let(:klass) do
      Class.new(::Hanami::Action) do
        def self.name
          'Web::Controllers::CustomersDatabase::Index'
        end

        before :a_before_callback
        after :an_after_callback

        private

        def a_before_callback; end
        def an_after_callback; end
      end
    end

    it_behaves_like 'a Hanami::Action with callbacks'
  end

  context 'with a nested action class' do
    let(:transaction_name) { 'Controller/web/admin_panel/customers_database/index' }

    let(:klass) do
      Class.new(::Hanami::Action) do
        def self.name
          'Web::Controllers::AdminPanel::CustomersDatabase::Index'
        end

        before :a_before_callback
        after :an_after_callback

        private

        def a_before_callback; end
        def an_after_callback; end
      end
    end

    it_behaves_like 'a Hanami::Action with callbacks'
  end
end
