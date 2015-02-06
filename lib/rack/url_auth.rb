require "rack/url_auth/version"
require "rack/url_auth/signer"
require "rack/url_auth/proxy"

module Rack
  class UrlAuth
    attr_reader :app, :signer, :forward_auth

    def initialize(app, opts = {})
      secret = opts[:secret] or
        raise(ArgumentError, 'Please provide `secret`')

      @app    = app
      @signer = Signer.new(secret)
      @forward_auth = !!opts[:forward_auth]
    end

    def call(env)
      proxy = env['rack.signature_auth'] = Proxy.new(env, signer)

      if !@forward_auth && !proxy.authorized?
        [403, {}, ['Forbidden']]
      else
        @app.call(env)
      end
    end
  end
end
