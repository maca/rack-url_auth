module Rack
  class UrlAuth
    class Proxy
      attr_reader :request, :signer

      def initialize(env, signer)
        @request = Rack::Request.new(env)
        @signer  = signer
      end

      def authorized?
        method = request.request_method.downcase
        signature_header = request.env["HTTP_X_SIGNATURE"]

        if !signature_header && request.get? || request.head?
          signer.verify_url(request.url, method)
        else
          body = request.body.read; request.body.rewind
          signer.verify(method + request.url + body, signature_header)
        end
      end
    end

  end
end
