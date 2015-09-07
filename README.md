![Rubygem](https://img.shields.io/gem/dv/netki/stable.svg)

# Ruby Netki Public Lookup API Client

This Ruby gem provides a client for [Netki's](https://netki.com) Public Lookup API.

This is forked from [Netki's Partner API Client](https://github.com/netkicorp/ruby-partner-client) to only include lookup functionality

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'netki-tether'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install netki-tether

## Usage

This gem provides a single command to lookup a Netki address.

Example:

```
require 'netki'

Netki.wallet_lookup("wallet.whitjack.bit", "BTC")
```

This would return `"17t9jJkx1XoVXXVR5kBkF34Dv14rQkzFHH"`

If a wallet is not resolved, it will return `[false, "No Address Found"]`

See rdoc-generated documentation for this Gem in doc/

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake false` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/netkicorp/ruby-partner-client.

