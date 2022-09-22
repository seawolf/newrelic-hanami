describe NewRelic::Agent::Instrumentation::Hanami do
  let(:instance) { klass.new }

  before do
    stub_const klass.name, klass
  end

  let(:request_params) { {} }
  let(:response)       { instance.call(request_params) }

  shared_examples 'a Hanami::Action' do
    it 'passes-through the response status code' do
      expect(response.status).to eq(200)
    end

    it 'passes-through the response headers' do
      expect(response.headers).to eq({
        'Content-Length' => response.body.first.length.to_s,
        'Content-Type'   =>  'application/octet-stream; charset=utf-8'
      })
    end

    it 'passes-through the response body' do
      expect(response.body).to eq(['hello'])
    end
  end

  context 'with a top-level action class' do
    let(:transaction_name) { 'Controller/web/customers_database/index' }

    let(:klass) do
      Class.new(::Hanami::Action) do
        def self.name
          'Web::Controllers::CustomersDatabase::Index'
        end

        def handle(_req, resp)
          resp.body = 'hello'
        end
      end
    end

    it 'traces the action with amended options (corrected name, etc.)' do
      expect_any_instance_of(::NewRelic::Agent::Transaction).to receive(:commit!).with(transaction_name)

      response
    end

    it_behaves_like 'a Hanami::Action'
  end

  context 'with a nested action class' do
    let(:transaction_name) { 'Controller/web/admin_panel/customers_database/index' }

    let(:klass) do
      Class.new(::Hanami::Action) do
        def self.name
          'Web::Controllers::AdminPanel::CustomersDatabase::Index'
        end

        def handle(_req, resp)
          resp.body = 'hello'
        end
      end
    end

    it 'traces the action with amended options (corrected name, etc.)' do
      expect_any_instance_of(::NewRelic::Agent::Transaction).to receive(:commit!).with(transaction_name)

      response
    end

    it_behaves_like 'a Hanami::Action'
  end

end
