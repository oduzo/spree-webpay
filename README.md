# Spree Webpay (Transbank)
==============

This is a integration of the [Acid Labs TBK Gem](https://github.com/acidlabs/tbk-webpay) into Spree Gateways.
Supports [Spree Multidomain](https://github.com/acidlabs/spree-multi-domain)

## Disclaimer

This extension was created for multi-domain spree

## Requirements

* Install in your project the e-commerce Connection Kit (KCC) from Transbank
* Follow the Transbank Webpay Integration manual to configure and set permissions to the directory tree and files.
* Serve your CGI scripts in your Web server

* This gem use rest_client, multi_logger and sidekiq to work on production.
* For sidekiq, add new queue "webpay":

```yaml
# config/sidekiq.yml

:queues:
  - default
  - webpay
```


## Usage

Set CGI URL and root path in config/tbk-webpay.yml

    production:
      cgi_base_url: "http://example.com/cgi"
      tbk_root_path: "/home/deploy/example.com/cgi"
    staging:
      cgi_base_url: "http://staging.example.com/cgi"
      tbk_root_path: "/home/deploy/staging.example.com/cgi"

## Mall Configuration

When using the gem with a Mall store, you must set in the backend the Store Code which is different from the Commerce Code. Remember also to set the 
`tbk_config.dat` accordingly.


## Installation
------------

Add spree_tbk_webpay to your Gemfile:

```ruby
gem 'spree_tbk_webpay'
```

Bundle your dependencies and run the installation generator:

```shell
bundle
bundle exec rails g spree_tbk_webpay:install
```

Run migrations

## Testing
-------

Be sure to bundle your dependencies and then create a dummy test app for the specs to run against.

```shell
bundle
bundle exec rake test_app
bundle exec rspec spec
```

When testing your applications integration with this extension you may use it's factories.
Simply add this require statement to your spec_helper:

```ruby
require 'spree_tbk_webpay/factories'
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Copyright (c) 2014 [Acid Labs](http://acid.cl), all right reserved.
