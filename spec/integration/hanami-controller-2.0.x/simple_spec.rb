# frozen_string_literal: true

describe '/simple' do
  include Rack::Test::Methods

  let(:app) { RSpec::HanamiApps::APP_CONTROLLER_2 }

  let(:response) { get '/simple' }

  it_behaves_like :a_web_request, body: 'This is a very simple example.'

  it 'traces the action with amended options (corrected name, etc.)' do
    expect_any_instance_of(NewRelic::Agent::Transaction).to receive(:commit!)
      .with('Controller/Simple/call')

    response
  end

  it 'has no sub-traces' do
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
                             { parent: 'Controller/Simple/call', name: 'Controller/Simple/handle' },
                             { parent: nil, name: 'Controller/Simple/call' }
                           ])
  end
end
