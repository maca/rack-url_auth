require 'hmac-sha2'
require 'addressable'

module Rack
  class UrlAuth
    class Signer
      attr_reader :secret

      def initialize(secret)
        @secret = secret
      end

      def sign(message)
        HMAC::SHA256.hexdigest(secret, message)
      end

      def verify(message, signature)
        actual = Digest::SHA1.hexdigest sign(message)
        expected = Digest::SHA1.hexdigest signature
        actual == expected
      end

      def sign_url(url, method)
        purl = Addressable::URI.parse url
        query = Rack::Utils.parse_query purl.query
        query['signature'] = sign(method.to_s.downcase + url)

        build_url(purl, query)
      end

      def verify_url(url, method)
        purl = Addressable::URI.parse url
        query = Rack::Utils.parse_query(purl.query)
        signature = query.delete('signature').to_s
        message = method.to_s.downcase + build_url(purl, query)

        verify(message, signature)
      end

      private
      def build_url(purl, query)
        purl.query = Rack::Utils.build_query(query)
        purl.normalize.to_s
      end
    end
  end
end
