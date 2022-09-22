describe NewRelic::Agent::Instrumentation::Hanami do
  subject do
    NewRelic::Agent::Instrumentation::ControllerInstrumentation
  end

  let(:request_params) { {} }
  let(:response)       { Web::Controllers::Home::Index.new.call(request_params) }

  before do
    stub_const 'Web::Controllers::Home::Index', Class.new(Hanami::Action)
    Web::Controllers::Home::Index.class_eval do
      def handle(_req, resp)
        resp.body = 'hello'
      end
    end
  end

  it 'calls perform_action_with_newrelic_trace with amended options' do
    expect_any_instance_of(subject).to receive(
      :perform_action_with_newrelic_trace).with({
        category: :controller,
        name:     "TODO HERE",
        request:  a_kind_of(Hanami::Action::Request),
        params:   request_params
      }).once

    response
  end

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
