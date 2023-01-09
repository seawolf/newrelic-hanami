# frozen_string_literal: true

describe '/with_callback' do
  include Rack::Test::Methods

  let(:app) { RSpec::HanamiApps::APP_CONTROLLER_2 }

  let(:response) { get '/with_callback' }

  it_behaves_like :a_web_request, body: 'This is an example of an action with one callback.'

  it 'traces the action with amended options (corrected name, etc.)' do
    expect_any_instance_of(NewRelic::Agent::Transaction).to receive(:commit!)
      .with('Controller/WithCallback/call')

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
                             { parent: 'Controller/WithCallback/call', name: 'Controller/WithCallback/before' },
                             { parent: 'Controller/WithCallback/call', name: 'Controller/WithCallback/handle' },
                             { parent: nil, name: 'Controller/WithCallback/call' }
                           ])
  end
end
