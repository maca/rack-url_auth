module Rack
  class UrlAuth
    class Signer
      attr_reader :secret

      def initialize(secret)
        @secret = secret
      end

      def sign(message)
        sha1 = OpenSSL::Digest::Digest.new('sha1')
        OpenSSL::HMAC.hexdigest sha1, secret, message
      end

      def verify(message, signature)
        actual   = Digest::SHA1.hexdigest sign(message)
        expected = Digest::SHA1.hexdigest signature
        actual == expected
      end

      def sign_url(url)
        purl  = URI.parse url
        query = Rack::Utils.parse_query purl.query
        query.merge! 'signature' => sign(url)

        build_url purl, query
      end

      def verify_url(url)
        purl      = URI.parse url
        query     = Rack::Utils.parse_query(purl.query)
        signature = query.delete('signature') or raise MissingSignature

        verify build_url(purl, query), signature
      end

      private
      def build_url(purl, query)
        query = Rack::Utils.build_query(query)
        url = "#{purl.scheme}://#{purl.host}#{':' + purl.port.to_s if purl.port}#{purl.path}"
        url = "#{url}?#{query}" unless query.empty?
        url
      end

      class MissingSignature < StandardError
      end
    end
  end
end