# Rack::UrlAuth

Rack::UrlAuth is a Rack middleware for HMAC URL authentication.

The most obvious use case would be a service that allows its users to perform
an action by clicking on an email sent to them, such as activating an
account, claiming a discount coupon or reseting a password.

The user would receive an email with a link to an url such as:
`http://example.org/accounts/1/activate?expires=2013-12-12&signature=bf3a53...`

Because any tampering with the query string or any other url component
can be detected, the service can tell if the person is authorized to
perform that action.

Keep in mind that **all GET actions should be idempotent**, meaning that
accessing them every time yields the same result.

Amazon S3, Braintree and may other services use this same principle to
authenticate requests by either signing the request body or the url.


## Installation

Add this line to your application's Gemfile:

    gem 'rack-url_auth'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-url_auth


## Usage

### Rails example


```ruby 
# config/application.rb
...

module MyApp
  class Application < Rails::Application
    config.middleware.use 'Rack::UrlAuth', secret: 'very-long-and-arbitrary-string'
    ...
  end
end

# controllers/application_controller.rb
class ApplicationController < ActionController::Base
  ...
  protected
  def authenticate_url!
    unless env['rack.url_auth'].url_authorized?
      render file: 'public/401', status: 401
    end
  end

  def sign_url(url)
    env['rack.url_auth'].sign_url url
  end
end

# controllers/private_stuff_controller.rb
class PrivateThingsController < ApplicationController
  before_filter :authenticate_url!, only: :view_private_thing

  def send_authorization
    signed_url = sign_url(view_private_thing_url(id: params[:id]))
    ApplicationMailer.
      private_thing_view_authorization(params[:email], signed_url).
      deliver
    ...
  end

  def view_private_thing
    # Not for you unless you are authorized ;)
    @thing = PrivateThing.find(params[:id])
    ...
  end
end
```


## Resources


* [Using HMAC to authenticate Web service requests](http://rc3.org/2011/12/02/using-hmac-to-authenticate-web-service-requests/)
* [Signed Idempotent Action Links](http://www.intridea.com/blog/2012/6/7/signed-idempotent-action-links)
* [Why you should never use hash functions for message authentication](http://blog.jcoglan.com/2012/06/09/why-you-should-never-use-hash-functions-for-message-authentication/)


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
