require 'spec_helper'

include Rack

describe UrlAuth do
  let(:secret)    { 'my-secretive-secret' }
  let(:inner_app) { double('App', call: []) }

  describe 'intantiation' do
    let(:signer) { double('Signer') }

    it 'requires a secret' do
      expect { UrlAuth.new(inner_app) }.
        to raise_error(ArgumentError)
    end

    it 'instantiates an signer' do
      expect(UrlAuth::Signer).
        to receive(:new).
        with(secret).
        and_return(signer)

      app = UrlAuth.new(inner_app, secret: secret)
      expect(app.signer).to be signer
    end
  end

  describe 'calling' do
    let(:app)   { UrlAuth.new(inner_app, secret: secret) }
    let(:env)   { { path: '/'} }
    let(:proxy) { double('Proxy') }

    it 'sets proxy as env variable' do
      expect(UrlAuth::Proxy).to receive(:new).
        with(env, app.signer).and_return(proxy)

      app.call(env)
      expect(env['rack.url_auth']).to be proxy
    end

    it 'forwards to app' do
      expect(inner_app).to receive(:call).with(env)
      app.call(env)
    end
  end
end
