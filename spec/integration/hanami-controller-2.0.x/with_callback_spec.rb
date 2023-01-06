# frozen_string_literal: true

describe '/with_callback' do
  include Rack::Test::Methods

  let(:app) { RSpec::HanamiApps::APP_CONTROLLER_2 }

  let(:response) { get '/with_callback' }

  it_behaves_like :a_web_request, body: 'This is an example of an action with one callback.'

  it 'traces the action with amended options (corrected name, etc.)' do
    expect_any_instance_of(NewRelic::Agent::Transaction).to receive(:commit!)
      .with('Controller/WithCallback')

    response
  end
end
