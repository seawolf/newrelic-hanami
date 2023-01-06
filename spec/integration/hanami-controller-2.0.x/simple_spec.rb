# frozen_string_literal: true

describe '/simple' do
  include Rack::Test::Methods

  let(:app) { RSpec::HanamiApps::APP_CONTROLLER_2 }

  let(:response) { get '/simple' }

  it_behaves_like :a_web_request, body: 'This is a very simple example.'

  it 'traces the action with amended options (corrected name, etc.)' do
    expect_any_instance_of(NewRelic::Agent::Transaction).to receive(:commit!)
      .with('Controller/Simple')

    response
  end
end
