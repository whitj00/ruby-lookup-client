require 'rubygems'
require 'bundler/setup'
require 'httpclient'
require 'json'
require_relative 'utilities'

module Netki

  # Request Utility Functionality
  def self.process_request(api_key, partner_id, uri, method, bodyData=nil)

    raise "Invalid HTTP Method" unless ['GET','POST','PUT','DELETE'].include? method

    # Setup Headers
    headers = {}
    headers["Content-Type"] = "application/json"
    headers["Authorization"] = api_key if api_key
    headers["X-Partner-ID"] = partner_id if partner_id

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

    # Process Error
    if response.code >= 300 || !ret_data['success']
      err = ret_data['message']
      if ret_data.has_key? 'failures'
        fails = []
        ret_data['failures'].each do |f|
          fails.push(f['message'])
        end
        err = err + "[FAILURES: " + fails.join(", ") + "]"
      end
      raise err
    end

    return ret_data
  end

  # Obtain a WalletName object by querying the Netki Open API.
  def self.wallet_lookup(uri, currency, api_url='https://api.netki.com')
    wallet_name = URI.parse(uri).host || uri.to_s

    response = process_request(nil, nil,
      "#{api_url}/api/wallet_lookup/#{wallet_name}/#{currency.downcase}", 'GET')

    domain_parts = response['wallet_name'].split('.')
    wallet_name = domain_parts.shift

    parsed = begin
               parse_bitcoin_uri(response['wallet_address']).merge(
                 {_raw: response['wallet_address']})
             rescue InvalidURIError => e
               response['wallet_address']
             end
    WalletName.new(
      domain_parts.join('.'), wallet_name,
      { response['currency'] => parsed }
    )
  end

##
# The WalletName object represents a Netki Wallet Name object.
#
  class WalletName

    ##
    # :args: domain_name, name, wallets, external_id, id,
    def initialize(domain_name, name, wallets={}, external_id: nil, id: nil)
      @domain_name = domain_name
      @name = name

      @wallets = wallets.inject({}) do |hsh, (currency, value)|
        hsh[currency] = value.is_a?(Hash) ? value : { address: value }
        hsh
      end
      @external_id = external_id
      @id = id
    end

    attr_accessor :domain_name, :name, :id, :external_id

    # :section: Getters

    # Get Address for Existing Currency
    def get_address(currency)
      @wallets[currency][:address]
    end

    # Get Wallet Name Array of Used Currencies
    def used_currencies
      @wallets.keys
    end

    # :section: Currency Address Operations

    # Set the address or URI for the given currency for this wallet name
    def set_currency_address(currency, address)
      @wallets[currency][:address] = address
    end

    # Remove a used currency from this wallet name
    def remove_currency(currency)
      @wallets.delete(currency) if @wallets.has_key? currency
    end

    # :section: Setters

    def set_api_opts(api_url, partner_id, api_key) # :nodoc:
      @api_url = api_url
      @partner_id = partner_id
      @api_key = api_key
    end

    # :section: Actions

    # Save the currency WalletName object to the remote service
    def save
      wallet_data = []
      @wallets.each do |currency, wallet|
        # NOTE: Unsure if remote service supports storing metadata (params/bip70 req)?
        wallet_data.push(
          {
            currency: currency,
            wallet_address: wallet[:_raw] ? wallet[:_raw] : wallet[:address]
          }
        )
      end

      wn_data = {
        domain_name: @domain_name,
        name: @name,
        wallets: wallet_data,
        external_id: @external_id || 'null'
      }

      wn_api_data = {}
      wn_api_data['wallet_names'] = [wn_data,]

      if @id
        wn_data['id'] = @id
        response = Netki.process_request(@api_key, @partner_id, "#{@api_url}/v1/partner/walletname", 'PUT', JSON.dump(wn_api_data))
      else
        response = Netki.process_request(@api_key, @partner_id, "#{@api_url}/v1/partner/walletname", 'POST', JSON.dump(wn_api_data))
      end

      unless @id
        response['wallet_names'].each do |wn|
          if response['success'] && wn['domain_name'] == @domain_name && wn['name'] == @name
            @id = wn['id']
          else
            raise 'Success, but invalid response received!'
          end
        end
      end

    end

    # Delete this WalletName object from the remote service
    def delete
      raise 'Unable to Delete Object that Does Not Exist Remotely' unless @id

      wn_api_data = {
          wallet_names: [{domain_name: @domain_name, id: @id}]
      }

      Netki.process_request(@api_key, @partner_id, "#{@api_url}/v1/partner/walletname", 'DELETE', JSON.dump(wn_api_data))
    end
  end

  class NetkiPartner

    ##
    # The Netki object must be initialized with the Partner ID and API Key to be useful
    #
    # * Partner ID -> Netki Partner ID is available on your partner API Key Page
    # * API Key -> Netki API Key is available only upon API Key creation. Be sure to store it somewhere safe!
    #

    attr_reader :partner_id
    attr_reader :api_key
    attr_reader :api_url

    attr_writer :partner_id
    attr_writer :api_key
    attr_writer :api_url

    def initialize(partner_id=nil, api_key=nil, api_url='https://api.netki.com')
      @partner_id = partner_id
      @api_key = api_key
      @api_url = api_url
    end

    ##
    # Create a new Partner
    # * partner_name -> Name of new sub-partner to create
    #
    def create_new_partner(partner_name)
      encoded_partner_name = URI.encode(partner_name)
      response = Netki.process_request(@api_key, @partner_id, "#{@api_url}/v1/admin/partner/#{encoded_partner_name}", method='POST')
      response['partner']['id']
    end

    ##
    # List current and sub partners
    # Returns a list of partner Hashes, each containing an id and name key
    #
    def get_partners()
      response = Netki.process_request(@api_key, @partner_id, "#{@api_url}/v1/admin/partner", method='GET')
      response['partners']
    end

    ##
    # Delete a Partner
    # * partner_name -> Name of sub-partner to delete
    # NOTE: You cannot delete your own partner resource
    #
    def delete_partner(partner_name)
      encoded_partner_name = URI.encode(partner_name)
      Netki.process_request(@api_key, @partner_id, "#{@api_url}/v1/admin/partner/#{encoded_partner_name}", method='DELETE')
      true
    end

    ##
    # Create a new domain
    # * domain_name -> Name of new domain to create
    # * partner_id -> (optional) Partner that should own the new domain
    #
    def create_new_domain(domain_name, partner_id=nil)
      api_data = {}
      api_data['partner_id'] = partner_id unless partner_id.nil?
      Netki.process_request(@api_key, @partner_id, "#{@api_url}/v1/partner/domain/#{domain_name}", method='POST', JSON.dump(api_data))
      true
    end

    ##
    # List available domain resources
    # Returns a list of domain Hashes, each containing a domain_name and tld_type key
    #
    def get_domains()
      response = Netki.process_request(@api_key, @partner_id, "#{@api_url}/api/domain", method='GET')
      response['domains']
    end

    ##
    # List status of domain resources
    # * domain_name -> (Optional) Name of domain to return status for
    #
    # If domain_name is omitted status is returned for all available domain resources.
    #
    # Returns a list of Hashes, each containing current status for each domain
    #
    def get_domain_status(domain_name=nil)

      uri="#{@api_url}/v1/partner/domain"
      uri << "/#{domain_name}" unless domain_name.nil?

      response = Netki.process_request(@api_key, @partner_id, uri, method='GET')
      response['domains']
    end

    ##
    # Get DNSSEC Status of Domain
    # * domain_name -> (Required) Name of domain to get DNSSEC status for
    #
    # Returns a hash containing the follow DNSSEC-related keys:
    # - ds_records (list)
    # - public_key_signing_key
    # - nextroll_date
    # - nameservers (list)

    def get_domain_dnssec(domain_name)
      Netki.process_request(@api_key, @partner_id, "#{@api_url}/v1/partner/domain/dnssec/#{domain_name}", method='GET')
    end

    ##
    # Delete a Domain
    # * domain_name -> Name of delete to delete
    #
    def delete_domain(domain_name)
      Netki.process_request(@api_key, @partner_id, "#{@api_url}/v1/partner/domain/#{domain_name}", method='DELETE')
      true
    end


    ##
    # Create a new Wallet Name object using this factory method.
    # * domain_name -> The pre-configured domain name you would like to add this new wallet name to
    # * name -> The DNS name that you would like this new wallet name to have (ie.. name.domain_name)
    # * wallets -> This is a hash where the key is the currency (ie.. btc, ltc, dgc, tusd) and the value is:
    #              the wallet address OR
    #              URL of the BIP32 / BIP70 address server OR
    #              a hash containing an :address and other metadata
    # * external_id -> Any unique external ID that you may want to use to track this specific wallet name
    #
    def create_new_walletname(domain_name, name, wallets={}, external_id=nil)
      new_wn = WalletName.new(domain_name, name, wallets, external_id)
      new_wn.set_api_opts(@api_url, @partner_id, @api_key)
      new_wn
    end

    ##
    # Returns an array of WalletName objects based on the given search parameters:
    # * domain_name -> The pre-configured domain that you have already been using for wallet names
    # * external_id -> The external ID previously given to the single wallet name you want to retrieve
    def get_wallet_names(domain_name=nil, external_id=nil)
      args = []
      args.push("domain_name=#{domain_name}") if domain_name
      args.push("external_id=#{external_id}") if external_id

      uri = "#{@api_url}/v1/partner/walletname"
      uri = (uri + "?" + args.join("&")) unless args.empty?
      response = Netki.process_request(@api_key, @partner_id, uri, method='GET')

      return [] if !response.has_key? 'wallet_name_count' || response['wallet_name_count'] == 0

      wn_list = []
      response['wallet_names'].each do |wn|
        wallets = {}
        wn['wallets'].each do |wallet|
          wallets[wallet['currency']] = wallet['wallet_address']
        end
        wn_obj = WalletName.new(wn['domain_name'], wn['name'], wallets, wn['external_id'], wn['id'])
        wn_obj.set_api_opts(@api_url, @partner_id, @api_key)
        wn_list.push(wn_obj)
      end
      wn_list
    end
  end
end
