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
                             { parent: 'Controller/Nested/WithCallbacks/call', name: 'before' },
                             # { parent: 'Controller/Nested/WithCallbacks/call', name: 'handle' },
                             { parent: 'Controller/Nested/WithCallbacks/call', name: 'after' },
                             { parent: nil, name: 'Controller/Nested/WithCallbacks/call' }
                           ])
  end
end
