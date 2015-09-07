require 'rubygems'
require 'bundler/setup'
require 'httpclient'
require 'json'

module Netki

  # Request Utility Functionality
  def self.process_request(api_key, partner_id, uri, method, bodyData=nil)

    raise "Invalid HTTP Method" unless ['GET','POST','PUT','DELETE'].include? method

    # Setup Headers
    headers = {}
    headers["Content-Type"] = "application/json"

    # Setup Request Options
    opts = {}
    opts[:header] = headers
    opts[:body] = bodyData if bodyData

    client = HTTPClient.new
    _uri = URI.parse(uri)
    response = client.request(method, _uri, opts)

    # Short Circuit Return if 204 Response on DELETE
    return {} if response.code == 204 && method == "DELETE"

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

  # Obtain a WalletName object by querying the Netki Open API.
  def self.wallet_lookup(uri, currency, api_url='https://api.netki.com')
    wallet_name = URI.parse(uri).host || uri.to_s

    response = process_request(nil, nil,
      "#{api_url}/api/wallet_lookup/#{wallet_name}/#{currency.downcase}", 'GET')
    
    netki_address = response['wallet_address']
    
    unless netki_address.nil? || netki_address == 0
      return netki_address
    else
      return false, "No Address Found"
    end
  end
end
