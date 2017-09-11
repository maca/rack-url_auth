require 'spec_helper'

include Rack

describe UrlAuth::Signer do
  let(:signer) { UrlAuth::Signer.new('my-secretive-secret') }

  describe 'signing and validating messages' do
    let(:message)          { 'HMAC is fun!!' }
    let(:tampered_message) { 'HMAC is fun!!!' }
    let(:signature)        { signer.sign message }

    it 'signs a messages' do
      expect(signature.size).to eq(64)
      expect(signer.verify(message, signature)).to be true
      expect(signer.verify(tampered_message, signature)).to be false
    end
  end

  describe 'signed urls' do
    let(:url)        { 'http://example.com/path?token=1&query=sumething' }
    let(:signed_url) { signer.sign_url url, 'get' }

    it 'appends signature' do
      expect(signed_url).to match %r{&signature=\w{64}}
    end

    it 'keeps params' do
      expect(signed_url).to include '?token=1&query=sumething'
    end

    it 'keeps host and path' do
      expect(signed_url).to match %r{http://example\.com/path}
    end

    it 'keeps port if different than 80' do
      signed_url = signer.
        sign_url 'http://example.com:3000/path?token=1&query=sumething', 'get'
      expect(signed_url).to match %{^http://example.com:3000}
    end

    it 'verifies untampered url' do
      expect( signer.verify_url(signed_url, 'get') ).to be true
    end

    it 'verifies false if url is tampered' do
      expect( signer.verify_url(signed_url.sub(/\.com/, '.me'), 'get') ).
        to be false
      expect( signer.verify_url(signed_url.sub('path', 'other-path'), 'get') ).
        to be false
      expect( signer.verify_url(signed_url.sub('1', '2'), 'get') ).
        to be false
    end

    it 'verifies that the method is correct' do
      expect( signer.verify_url(signed_url, 'delete') ).to be false
    end

    it 'raises error when url is unsigned while verifying url' do
      expect(signer.verify_url 'http://example.com', 'get').to be false
    end

    it 'normalizes url' do
      signed_url = signer.
        sign_url 'http://example.com/path?token=1&query=sumething:else', 'get'
      expect( signer.verify_url(signed_url, 'get') ).to be true
    end
  end
end
