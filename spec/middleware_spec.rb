require 'spec_helper'

include Rack

describe UrlAuth do
  let(:secret)    { 'my-secretive-secret' }
  let(:inner_app) { double('App', call: []) }

  it { UrlAuth::VERSION.should eq '0.0.1' }

  describe 'intantiation' do
    let(:signer) { double('Signer') }

    it 'requires a secret' do
      expect { UrlAuth.new(inner_app) }.
        to raise_error(ArgumentError)
    end

    it 'instantiates an signer' do
      UrlAuth::Signer.
        should_receive(:new).
        with(secret).
        and_return(signer)

      app = UrlAuth.new(inner_app, secret: secret)
      app.signer.should be signer
    end
  end

  describe 'calling' do
    let(:app)   { UrlAuth.new(inner_app, secret: secret) }
    let(:env)   { { path: '/'} }
    let(:proxy) { double('Proxy') }

    it 'sets proxy as env variable' do
      UrlAuth::Proxy.should_receive(:new).
        with(env, app.signer).and_return(proxy)

      app.call(env)
      env['rack.url_auth'].should be proxy
    end

    it 'forwards to app' do
      inner_app.should_receive(:call).with(env)
      app.call(env)
    end
  end
end
