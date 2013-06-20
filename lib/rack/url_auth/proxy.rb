module Rack
  class UrlAuth
    class Proxy
      attr_reader :request, :signer

      def initialize(env, signer)
        @request = Rack::Request.new(env)
        @signer  = signer
      end

      def url_authorized?
        signer.verify_url(request.url)
      end

      def sign_url(url)
        signer.sign_url(url)
      end
    end
  end
end
