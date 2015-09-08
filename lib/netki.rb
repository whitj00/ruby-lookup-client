require 'rubygems'
require 'bundler/setup'
require 'httpclient'
require 'json'

# Responsible for all classes in the Netki-Tether gem
module Netki

  # Request Utility Functionality
  def self.process_request(uri)
    # Setup Headers
    headers = {}
    headers["Content-Type"] = "application/json"

    # Setup Request Options
    opts = {}
    opts[:header] = headers
    method = 'GET'

    client = HTTPClient.new
    _uri = URI.parse(uri)
    response = client.request(method, _uri, opts)

    # We should have response content at this point
    raise "Empty Response Received" if response.content.nil? || response.content.empty?

    # Verify we have the correct content type
    raise "Non-JSON Content Type" if response.headers['Content-Type'] != 'application/json'

    # Make Sure We Can Decode JSON Response
    begin
      ret_data = JSON.parse(response.content)
    rescue JSON::ParserError => e
      raise "Invalid JSON Response Received"
    end
    return ret_data
  end

  # Query the Netki Open API for an address
  def self.wallet_lookup(uri, currency, api_url='https://api.netki.com')
    wallet_name = URI.parse(uri).host || uri.to_s

    response = process_request("#{api_url}/api/wallet_lookup/#{wallet_name}/#{currency.downcase}")

    netki_address = response['wallet_address']

    if !netki_address.nil? && netki_address != 0
      return netki_address
    else
      return false, "No Address Found"
    end
  end

end
