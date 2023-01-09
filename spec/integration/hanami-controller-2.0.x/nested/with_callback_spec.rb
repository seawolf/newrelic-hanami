# frozen_string_literal: true

describe '/nested/with_callback' do
  include Rack::Test::Methods

  let(:app) { RSpec::HanamiApps::APP_CONTROLLER_2 }

  let(:response) { get '/nested/with_callback' }

  it_behaves_like :a_web_request, body: 'This is an example of a nested action with one callback.'

  it 'traces the action with amended options (corrected name, etc.)' do
    expect_any_instance_of(NewRelic::Agent::Transaction).to receive(:commit!)
      .with('Controller/Nested/WithCallback/call')

    response
  end

  it 'traces the callback as a distinct part of the whole transaction' do
    segments = []

    allow_any_instance_of(NewRelic::Agent::Transaction::Segment).to receive(:segment_complete) do |segment|
      segments << {
        parent: segment.parent&.name,
        name: segment.name
      }
    end

    response

    # Ordered by finishing time; the parent starts first but finishes last
    expect(segments).to eq([
                             { parent: 'Controller/Nested/WithCallback/call', name: 'Controller/Nested/WithCallback/before' },
                             { parent: 'Controller/Nested/WithCallback/call', name: 'Controller/Nested/WithCallback/handle' },
                             { parent: nil, name: 'Controller/Nested/WithCallback/call' }
                           ])
  end
end
