# frozen_string_literal: true

describe NewRelic::Agent::Instrumentation::Hanami do
  let(:instance) { klass.new }

  before do
    stub_const klass.name, klass
  end

  let(:request_params) { {} }
  let(:response)       { instance.call(request_params) }

  context 'with a top-level action class' do
    let(:klass) do
      Class.new(Hanami::Action) do
        def self.name
          'Web::Controllers::CustomersDatabase::Index'
        end

        def handle(_req, resp)
          resp.body = 'hello'
        end
      end
    end

    it 'traces the action with amended options (corrected name, etc.)' do
      expect_any_instance_of(NewRelic::Agent::Transaction).to receive(:commit!)
        .with("Controller/Web/Controllers/CustomersDatabase/Index")

      response
    end

    it_behaves_like :a_web_request, body: ['hello']
  end

  context 'with a nested action class' do
    let(:klass) do
      Class.new(Hanami::Action) do
        def self.name
          'Web::Controllers::AdminPanel::CustomersDatabase::Index'
        end

        def handle(_req, resp)
          resp.body = 'hello'
        end
      end
    end

    it 'traces the action with amended options (corrected name, etc.)' do
      expect_any_instance_of(NewRelic::Agent::Transaction).to receive(:commit!)
        .with("Controller/Web/Controllers/AdminPanel/CustomersDatabase/Index")

      response
    end

    it_behaves_like :a_web_request, body: ['hello']
  end
end
