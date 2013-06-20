require "rack/url_auth/version"
require "rack/url_auth/signer"
require "rack/url_auth/proxy"

module Rack
  class UrlAuth
    attr_reader :app, :signer

    def initialize(app, opts = {})
      secret = opts[:secret] or raise(ArgumentError, 'Please provide `secret`')
      @app, @signer = app, Signer.new(secret)
    end

    def call(env)
      env['rack.url_auth'] = Proxy.new(env, signer)
      @app.call(env)
    end
  end
end
