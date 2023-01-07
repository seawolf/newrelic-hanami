# frozen_string_literal: true

shared_examples :a_web_request do |**args|
  it 'passes-through the response status code' do
    expect(response.status).to eq(200)
  end

  it 'passes-through the response headers' do
    length = if args[:body].is_a?(Array)
               args[:body].first.length
             else
               args[:body].length
             end

    expect(response.headers).to eq({
                                     'Content-Length' => length.to_s,
                                     'Content-Type' => 'application/octet-stream; charset=utf-8'
                                   })
  end

  it 'passes-through the response body' do
    expect(response.body).to eq(args[:body])
  end
end
