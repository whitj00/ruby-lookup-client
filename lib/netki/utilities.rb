module Netki

  KNOWN_PREFIXES = [ 'bitcoin', 'litecoin', 'dogecoin' ]

  class InvalidURIError < StandardError; end

  def self.parse_bitcoin_uri(uri, tolerate_errors: false)
    parts = uri.split(':', 2)

    unless KNOWN_PREFIXES.include?(parts.shift)
      raise InvalidURIError.new("unknown URI prefix")
    end

    # parts => [base58][?[bitcoinparam, [&bitcoinparam, ...]]
    base58address, query = parts.first.split('?', 2)
    response = { address: base58address }

    begin
      response.merge!(_parse_bip_72(query))
    rescue InvalidURIError => e
      raise e unless tolerate_errors
    end

    response
  end

  # https://github.com/bitcoin/bips/blob/master/bip-0072.mediawiki
  def self._parse_bip_72(querystring)
    params = _parse_bip_21(querystring)
    { r: params['r'], params: params }
  end

  # https://github.com/bitcoin/bips/blob/master/bip-0021.mediawiki
  def self._parse_bip_21(querystring)

    param_pairs = querystring.split('&') # '&' reserved as separator in bip21

    param_pairs.inject({}) do |hsh, pair|
      parts = pair.split('=') # '=' reserved as separator in bip21

      raise InvalidURIError.new("unbalanced parameter #{pair}") unless (
        parts.size == 2 &&
        parts[0].size > 0 &&
        parts[1].size > 0)
      raise InvalidURIError.new("duplicate parameter #{parts[0]}") unless hsh[parts[0]].nil?

      hsh[parts[0]] = parts[1]
      hsh
    end
  end
end
