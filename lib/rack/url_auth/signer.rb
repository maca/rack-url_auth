require 'hmac-sha2'

module Rack
  class UrlAuth
    class Signer
      attr_reader :secret

      def initialize(secret)
        @secret = secret
      end

      def sign(message)
        HMAC::SHA256.hexdigest secret, message
      end

      def verify(message, signature)
        actual   = Digest::SHA1.hexdigest sign(message)
        expected = Digest::SHA1.hexdigest signature
        actual == expected
      end

      def sign_url(url, method)
        purl  = URI.parse url
        query = Rack::Utils.parse_query purl.query
        query.merge! 'signature' => sign(method.to_s.downcase + url)

        build_url purl, query
      end

      def verify_url(url, method)
        purl      = URI.parse url
        query     = Rack::Utils.parse_query(purl.query)
        signature = query.delete('signature').to_s

        verify method.to_s.downcase + build_url(purl, query), signature
      end

      private
      def build_url(purl, query)
        query    = Rack::Utils.build_query(query)

        unless purl.scheme
          raise(ArgumentError, 'URI protocol must be provided')
        end

        url_ary = [purl.scheme, '://', purl.host]
        url_ary.push( ':', purl.port ) unless [80, 443, nil].include?(purl.port)
        url_ary.push( purl.path )
        url_ary.push( '?', query ) unless query.empty?
        url_ary.join
      end
    end
  end
end
