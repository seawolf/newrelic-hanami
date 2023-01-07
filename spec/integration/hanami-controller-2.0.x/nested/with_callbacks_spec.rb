# frozen_string_literal: true

describe '/nested/with_callbacks' do
  include Rack::Test::Methods

  let(:app) { RSpec::HanamiApps::APP_CONTROLLER_2 }

  let(:response) { get '/nested/with_callbacks' }

  it_behaves_like :a_web_request, body: 'This is an example of a nested action with Before and After callbacks.'

  it 'traces the action with amended options (corrected name, etc.)' do
    expect_any_instance_of(NewRelic::Agent::Transaction).to receive(:commit!)
      .with('Controller/Nested/WithCallbacks/call')

    response
  end
end
