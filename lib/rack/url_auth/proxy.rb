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

        if request.get? || request.delete? || request.head? || request.options?
          signer.verify_url(request.url, method)
        else
          body      = request.body.read; request.body.rewind
          signature = request.env["HTTP_X_SIGNATURE"]
          signer.verify(request.url + method + body, signature)
        end
      end
    end

  end
end
