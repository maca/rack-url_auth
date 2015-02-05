require 'spec_helper'

include Rack

describe UrlAuth::Proxy do
  let(:env)    { Rack::MockRequest.env_for('/home?signature=mock') }
  let(:signer) { double('Signer') }
  let(:proxy)  { UrlAuth::Proxy.new(env, signer) }

  describe 'signing urls' do
    it 'signs a url' do
      expect(signer).
        to receive(:sign_url).
        and_return('/home?signature=mock')

      expect(proxy.sign_url('/home')).
        to eq '/home?signature=mock'
    end
  end

  describe 'signer' do
    it 'authorizes url' do
      expect(signer).
        to receive(:verify_url).
        with('http://example.org/home?signature=mock').
        and_return(true)

      expect(proxy.url_authorized?).to be true
    end

    it 'returns false for tampered url' do
      expect(signer).
        to receive(:verify_url).
        with('http://example.org/home?signature=mock').
        and_return(false)

      expect(proxy.url_authorized?).to be false
    end
  end
end
