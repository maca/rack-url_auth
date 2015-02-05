require 'spec_helper'

include Rack

describe UrlAuth::Proxy do
  let(:env)    { Rack::MockRequest.env_for('/home?signature=mock') }
  let(:signer) { double('Signer') }
  let(:proxy)  { UrlAuth::Proxy.new(env, signer) }

  describe 'signing urls' do
    it 'signs a url' do
      signer.
        should_receive(:sign_url).
        and_return('/home?signature=mock')

      proxy.sign_url('/home').
        should eq '/home?signature=mock'
    end
  end

  describe 'signer' do
    it 'authorizes url' do
      signer.
        should_receive(:verify_url).
        with('http://example.org/home?signature=mock').
        and_return(true)

      proxy.url_authorized?.should be true
    end

    it 'returns false for tampered url' do
      signer.
        should_receive(:verify_url).
        with('http://example.org/home?signature=mock').
        and_return(false)

      proxy.url_authorized?.should be false
    end
  end
end
