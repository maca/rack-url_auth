require 'spec_helper'

describe Rack::UrlAuth do
  include Rack::Test::Methods

  let(:secret)    { 'secretive-secret' }
  let(:inner_app) { ->(env){ [200,{},['Hello, world.']] } }
  let(:app)       { Rack::UrlAuth.new(inner_app, secret: secret) }

  describe 'instantiation' do
    it 'requires a secret' do
      expect { Rack::UrlAuth.new(app) }.to raise_error ArgumentError
    end
  end

  describe 'request without body' do
    let(:signature) {
      'b645417491551a215286db40cd3fbdd97c7e2f146b2feb0ae5f32f03537ed343'
    }

    it 'authorizes request' do
      get "/index?signature=#{signature}"
      expect( last_request.env['rack.signature_auth'] ).to be_authorized
    end

    it 'forbids request if url is tampered' do
      get "/forbid?signature=#{signature}"
      expect( last_request.env['rack.signature_auth'] ).not_to be_authorized
    end

    it 'forbids request if method is incorrect' do
      head "/index?signature=#{signature}"
      expect( last_request.env['rack.signature_auth'] ).not_to be_authorized
    end
  end


  describe 'request with body' do
    let(:signature) {
      'bab5dd78fce9f4fd85c5037466c5a5e22cf67ba14f25005f499ddc7820710475'
    }

    it 'autorizes request' do
      header 'X-Signature', signature
      post '/index', name: 'Macario'
      expect( last_request.env['rack.signature_auth'] ).to be_authorized
    end

    it 'forbids request if url is tampered' do
      header 'X-Signature', signature
      post '/forbid', name: 'Macario'
      expect( last_request.env['rack.signature_auth'] ).not_to be_authorized
    end

    it 'forbids request if body is tampered' do
      header 'X-Signature', signature
      post '/index', name: 'Juan'
      expect( last_request.env['rack.signature_auth'] ).not_to be_authorized
    end

    it 'forbids request if method is incorrect' do
      header 'X-Signature', signature
      put '/index', name: 'Macario'
      expect( last_request.env['rack.signature_auth'] ).not_to be_authorized
    end
  end

  describe 'handling authentication' do
    context 'not forwarding auth to app' do
      let(:app) { Rack::UrlAuth.new(inner_app, secret: secret) }

      it 'returns forbidden status code' do
        get "/forbid"
        expect( last_response.status ).to eq 403
      end
    end

    context 'forwarding auth to app' do
      let(:app) { Rack::UrlAuth.new(inner_app,
                                    forward_auth: true, secret: secret) }

      it 'returns forbidden status code' do
        get "/forbid"
        expect( last_response.status ).to eq 200
      end
    end
  end
end
