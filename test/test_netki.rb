require 'test/unit'
require 'mocha/test_unit'
require 'webmock/test_unit'
require_relative '../lib/netki/netki'

class TestNetki < Test::Unit::TestCase

  def setup
    @resp_data = {
        "success" => true,
        "message" => "",
        "failures" => []
    }
    @resp_body = JSON.dump(@resp_data)

    @resp_headers = {'Content-Type' => 'application/json'}
  end

  def test_process_request_go_right

    stub_request(:post, "https://api.netki.com/").
        with(:body => "bob",
             :headers => {'Accept'=>'*/*', 'Authorization'=>'api_key', 'Content-Type'=>'application/json', 'Date'=> /.*/, 'User-Agent'=>/.*/, 'X-Partner-Id'=>'partner_id'}).to_return(:status => 200, :body => @resp_body, :headers => @resp_headers)

    resp = Netki.process_request('api_key', 'partner_id', 'https://api.netki.com', 'POST', 'bob')

    assert_not_nil(resp)
    assert_true(resp['success'])
    assert_equal("", resp['message'])
    assert_equal([], resp['failures'])
  end

  def test_process_request_get_nodata

    stub_request(:get, "https://api.netki.com/").
        with(:headers => {'Accept'=>'*/*', 'Authorization'=>'api_key', 'Content-Type'=>'application/json', 'Date'=> /.*/, 'User-Agent'=>/.*/, 'X-Partner-Id'=>'partner_id'}).to_return(:status => 200, :body => @resp_body, :headers => @resp_headers)

    resp = Netki.process_request('api_key', 'partner_id', 'https://api.netki.com', 'GET')

    assert_not_nil(resp)
    assert_true(resp['success'])
    assert_equal("", resp['message'])
    assert_equal([], resp['failures'])
  end

  def test_process_request_invalid_method

    stub_request(:post, "https://api.netki.com/").
        with(:body => "bob",
             :headers => {'Accept'=>'*/*', 'Authorization'=>'api_key', 'Content-Type'=>'application/json', 'Date'=> /.*/, 'User-Agent'=>/.*/, 'X-Partner-Id'=>'partner_id'}).to_return(:status => 200, :body => @resp_body, :headers => @resp_headers)

    assert_raise "Invalid HTTP Method" do
      Netki.process_request('api_key', 'partner_id', 'https://api.netki.com', 'HEAD', 'bob')
    end

  end

  def test_process_request_204_delete

    @resp_body = ""
    stub_request(:delete, "https://api.netki.com/").
        with(:body => "bob",
             :headers => {'Accept'=>'*/*', 'Authorization'=>'api_key', 'Content-Type'=>'application/json', 'Date'=> /.*/, 'User-Agent'=>/.*/, 'X-Partner-Id'=>'partner_id'}).to_return(:status => 204, :body => @resp_body, :headers => @resp_headers)

    resp = Netki.process_request('api_key', 'partner_id', 'https://api.netki.com', 'DELETE', 'bob')

    assert_equal({}, resp)

  end

  def test_process_request_nil_content

    stub_request(:post, "https://api.netki.com/").
        with(:body => "bob",
             :headers => {'Accept'=>'*/*', 'Authorization'=>'api_key', 'Content-Type'=>'application/json', 'Date'=> /.*/, 'User-Agent'=>/.*/, 'X-Partner-Id'=>'partner_id'}).to_return(:status => 200, :body => nil, :headers => @resp_headers)

    assert_raise "Empty Response Received" do
      Netki.process_request('api_key', 'partner_id', 'https://api.netki.com', 'POST', 'bob')
    end

  end

  def test_process_request_empty_content

    @resp_body = ""
    stub_request(:post, "https://api.netki.com/").
        with(:body => "bob",
             :headers => {'Accept'=>'*/*', 'Authorization'=>'api_key', 'Content-Type'=>'application/json', 'Date'=> /.*/, 'User-Agent'=>/.*/, 'X-Partner-Id'=>'partner_id'}).to_return(:status => 200, :body => @resp_body, :headers => @resp_headers)

    assert_raise "Empty Response Received" do
      Netki.process_request('api_key', 'partner_id', 'https://api.netki.com', 'POST', 'bob')
    end

  end

  def test_process_request_bad_content_type
    @resp_headers['Content-Type'] = 'text/plain'
    @resp_body = ""
    stub_request(:post, "https://api.netki.com/").
        with(:body => "bob",
             :headers => {'Accept'=>'*/*', 'Authorization'=>'api_key', 'Content-Type'=>'application/json', 'Date'=> /.*/, 'User-Agent'=>/.*/, 'X-Partner-Id'=>'partner_id'}).to_return(:status => 200, :body => @resp_body, :headers => @resp_headers)

    assert_raise "Non-JSON Content Type" do
      Netki.process_request('api_key', 'partner_id', 'https://api.netki.com', 'POST', 'bob')
    end

  end

  def test_process_request_non_json_data

    @resp_body = "NON_JSON_DATA{}!"
    stub_request(:post, "https://api.netki.com/").
        with(:body => "bob",
             :headers => {'Accept'=>'*/*', 'Authorization'=>'api_key', 'Content-Type'=>'application/json', 'Date'=> /.*/, 'User-Agent'=>/.*/, 'X-Partner-Id'=>'partner_id'}).to_return(:status => 200, :body => @resp_body, :headers => @resp_headers)

    assert_raise "Invalid JSON Response Received" do
      Netki.process_request('api_key', 'partner_id', 'https://api.netki.com', 'POST', 'bob')
    end

  end

  def test_process_request_400_error

    @resp_data['success'] = false
    @resp_data['message'] = "Bad Request Error Message"
    @resp_body = JSON.dump(@resp_data)

    stub_request(:post, "https://api.netki.com/").
        with(:body => "bob",
             :headers => {'Accept'=>'*/*', 'Authorization'=>'api_key', 'Content-Type'=>'application/json', 'Date'=> /.*/, 'User-Agent'=>/.*/, 'X-Partner-Id'=>'partner_id'}).to_return(:status => 400, :body => @resp_body, :headers => @resp_headers)

    assert_raise "Bad Request Error Message" do
      Netki.process_request('api_key', 'partner_id', 'https://api.netki.com', 'POST', 'bob')
    end

  end

  def test_process_request_success_false

    @resp_data['success'] = false
    @resp_data['message'] = "Error Message"
    @resp_body = JSON.dump(@resp_data)

    stub_request(:post, "https://api.netki.com/").
        with(:body => "bob",
             :headers => {'Accept'=>'*/*', 'Authorization'=>'api_key', 'Content-Type'=>'application/json', 'Date'=> /.*/, 'User-Agent'=>/.*/, 'X-Partner-Id'=>'partner_id'}).to_return(:status => 200, :body => @resp_body, :headers => @resp_headers)

    assert_raise "Error Message" do
      Netki.process_request('api_key', 'partner_id', 'https://api.netki.com', 'POST', 'bob')
    end

  end

  def test_process_request_success_false_failures

    @resp_data['success'] = false
    @resp_data['message'] = "Error Message"
    @resp_data['failures'].push({message: "Failure 1" })
    @resp_data['failures'].push({message: "Failure 42" })
    @resp_body = JSON.dump(@resp_data)

    stub_request(:post, "https://api.netki.com/").
        with(:body => "bob",
             :headers => {'Accept'=>'*/*', 'Authorization'=>'api_key', 'Content-Type'=>'application/json', 'Date'=> /.*/, 'User-Agent'=>/.*/, 'X-Partner-Id'=>'partner_id'}).to_return(:status => 200, :body => @resp_body, :headers => @resp_headers)

    assert_raise "Error Message [FAILURES: Failure 1, Failure 42]" do
      Netki.process_request('api_key', 'partner_id', 'https://api.netki.com', 'POST', 'bob')
    end

  end

end

class TestWalletName < Test::Unit::TestCase

  def setup

    # Save Data
    @req_data = {
        wallet_names: [
            {domain_name: 'domain.com', name: 'name', wallets: [
                {currency: 'btc', wallet_address: '1Zjkhglkjhgfdslkfg'}
            ], external_id: 'external_id'}
        ]
    }

    @resp_data = {"success" => true,
                  "wallet_names" => [{
                                     "domain_name" => 'domain.com',
                                     "name" => 'name',
                                     "id" => 'test_id'
                                 }]}

    # Delete Data
    @delete_req_data = {wallet_names: [
        {domain_name: 'domain.com', id: 'id'}]
    }
    @delete_resp_data = {"success" => true,
                         "wallet_names" => [{
                                            "domain_name" => 'domain.com',
                                            "name" => 'name',
                                            "id" => 'test_id'
                                        }]}

  end

  def test_object_creation
    @obj = Netki::WalletName.new('domain.com', 'name', {'btc' => '1Zjkhglkjhgfdslkfg'}, 'external_id', 'id')
    assert_equal('domain.com', @obj.domain_name)
    assert_equal('name', @obj.name)
    assert_equal('external_id', @obj.external_id)
    assert_equal('id', @obj.id)
    assert(@obj.used_currencies.include? 'btc')
    assert_equal('1Zjkhglkjhgfdslkfg', @obj.get_address('btc'))
  end

  def test_set_currency_address
    @obj = Netki::WalletName.new('domain.com', 'name', {}, 'external_id', 'id')
    @obj.set_currency_address('btc', '1Zjkhglkjhgfdslkfg')
    assert_equal('1Zjkhglkjhgfdslkfg', @obj.get_address('btc'))
  end

  def test_remove_currency
    @obj = Netki::WalletName.new('domain.com', 'name', {'btc' => '1Zjkhglkjhgfdslkfg'}, 'external_id', 'id')
    @obj.remove_currency('btc')
    assert_nil(@obj.get_address('btc'))
  end

  def test_save_new_success
    @obj = Netki::WalletName.new('domain.com', 'name', {'btc' => '1Zjkhglkjhgfdslkfg'}, 'external_id')
    Netki.expects(:process_request).with(nil, nil, '/v1/partner/walletname', 'POST', JSON.dump(@req_data)).returns(@resp_data)

    @obj.save
    assert_equal('test_id', @obj.id)
  end

  def test_save_new_success_with_incorrect_response

    @resp_data['wallet_names'][0]['domain_name'] = 'wrongdomain.com'

    @obj = Netki::WalletName.new('domain.com', 'name', {'btc' => '1Zjkhglkjhgfdslkfg'}, 'external_id')
    Netki.expects(:process_request).with(nil, nil, '/v1/partner/walletname', 'POST', JSON.dump(@req_data)).returns(@resp_data)

    begin
      @obj.save
      assert(false)
    rescue Exception => e
      assert_equal('Success, but invalid response received!', e.message)
    end
    assert_nil(@obj.id)
  end

  def test_save_update_success

    @req_data[:wallet_names][0][:id] = 'id'

    @obj = Netki::WalletName.new('domain.com', 'name', {'btc' => '1Zjkhglkjhgfdslkfg'}, 'external_id', 'id')
    Netki.expects(:process_request).with(nil, nil, '/v1/partner/walletname', 'PUT', JSON.dump(@req_data)).returns(@resp_data)
    @obj.save
    assert_equal('id', @obj.id)
  end

  def test_delete_success
    Netki.expects(:process_request).with(nil, nil, '/v1/partner/walletname', 'DELETE', JSON.dump(@delete_req_data)).returns(@delete_resp_obj)
    @obj = Netki::WalletName.new('domain.com', 'name', {'btc' => '1Zjkhglkjhgfdslkfg'}, 'external_id', 'id')
    @obj.delete
  end
end

class TestNetkiPartner < Test::Unit::TestCase

  def setup

    @ret_obj = {"success" => true,
                           "wallet_name_count" => 2,
                           "wallet_names" => [{
                                              "domain_name" => "domain.com",
                                              "name" => "name",
                                              "id" => "test_id",
                                              "wallets" => [
                                                  {"currency" => "btc", "wallet_address" => "1234567890"},
                                                  {"currency" => "dgc", "wallet_address" => "D1234567890"}
                                              ]
                                          },{
                                             "domain_name" => "domain2.com",
                                             "name" => "name",
                                             "id" => "test_id_2",
                                             "wallets" => [
                                                 {"currency" => "btc", "wallet_address" => "0987654321"},
                                                 {"currency" => "dgc", "wallet_address" => "D0987654321"}
                                             ]
                                         }]
                          }
  end

  def test_default_arg
    @obj = Netki::NetkiPartner.new('partner_id', 'api_key')
    assert_equal('partner_id', @obj.partner_id)
    assert_equal('api_key', @obj.api_key)
    assert_equal('https://api.netki.com', @obj.api_url)
  end

  def test_init_all_args
    @obj = Netki::NetkiPartner.new('partner_id', 'api_key', 'api_url')
    assert_equal('partner_id', @obj.partner_id)
    assert_equal('api_key', @obj.api_key)
    assert_equal('api_url', @obj.api_url)
  end

  # Test Wallet Name handling
  def test_create_new_walletname

    Netki::WalletName.any_instance.expects(:new).with('domain.com', 'name', {btc: '1234567890'}, 'external_id').once
    Netki::WalletName.any_instance.expects(:set_api_opts).with('api_url', 'partner_id', 'api_key').once

    @obj = Netki::NetkiPartner.new('partner_id', 'api_key', 'api_url')
    @wn = @obj.create_new_walletname('domain.com', 'name', {btc: '1234567890'}, 'external_id')

    assert_not_nil @wn
    assert_equal('domain.com', @wn.domain_name)
    assert_equal('name', @wn.name)
    assert_equal('external_id', @wn.external_id)
    assert_equal('1234567890' ,@wn.get_address(:btc))

    Netki::WalletName.any_instance.unstub(:new)
    Netki::WalletName.any_instance.unstub(:set_api_opts)

  end

  def test_get_wallet_names_go_right
    Netki.expects(:process_request).with('api_key', 'partner_id', 'api_url/v1/partner/walletname?domain_name=domain.com&external_id=ext_id', 'GET').returns(@ret_obj)
    Netki::WalletName.any_instance.expects(:new).twice
    Netki::WalletName.any_instance.expects(:set_api_opts).with('api_url', 'partner_id', 'api_key').twice

    @obj = Netki::NetkiPartner.new('partner_id', 'api_key', 'api_url')
    @wn_list = @obj.get_wallet_names('domain.com', 'ext_id')

    assert_not_nil @wn_list
    assert_equal(2, @wn_list.length)

    Netki.unstub(:process_request)
    Netki::WalletName.any_instance.unstub(:new)
    Netki::WalletName.any_instance.unstub(:set_api_opts)
  end

  def test_get_wn_only_domain_name
    Netki.expects(:process_request).with('api_key', 'partner_id', 'api_url/v1/partner/walletname?domain_name=domain.com', 'GET').returns(@ret_obj)
    Netki::WalletName.any_instance.expects(:new).twice
    Netki::WalletName.any_instance.expects(:set_api_opts).with('api_url', 'partner_id', 'api_key').twice

    @obj = Netki::NetkiPartner.new('partner_id', 'api_key', 'api_url')
    @wn_list = @obj.get_wallet_names('domain.com')

    assert_not_nil @wn_list
    assert_equal(2, @wn_list.length)

    Netki::NetkiPartner.any_instance.unstub(:submit_request)
    Netki::WalletName.any_instance.unstub(:new)
    Netki::WalletName.any_instance.unstub(:set_api_opts)
  end

  def test_get_wn_only_external_id
    Netki.expects(:process_request).with('api_key', 'partner_id', 'api_url/v1/partner/walletname?external_id=ext_id', 'GET').returns(@ret_obj)
    Netki::WalletName.any_instance.expects(:new).twice
    Netki::WalletName.any_instance.expects(:set_api_opts).with('api_url', 'partner_id', 'api_key').twice

    @obj = Netki::NetkiPartner.new('partner_id', 'api_key', 'api_url')
    @wn_list = @obj.get_wallet_names(nil, "ext_id")

    assert_not_nil @wn_list
    assert_equal(2, @wn_list.length)

    Netki::NetkiPartner.any_instance.unstub(:submit_request)
    Netki::WalletName.any_instance.unstub(:new)
    Netki::WalletName.any_instance.unstub(:set_api_opts)
  end

  def test_get_wn_go_right_no_args
    Netki.expects(:process_request).with('api_key', 'partner_id', 'api_url/v1/partner/walletname', 'GET').returns(@ret_obj)
    Netki::WalletName.any_instance.expects(:new).twice
    Netki::WalletName.any_instance.expects(:set_api_opts).with('api_url', 'partner_id', 'api_key').twice

    @obj = Netki::NetkiPartner.new('partner_id', 'api_key', 'api_url')
    @wn_list = @obj.get_wallet_names(nil, nil)

    assert_not_nil @wn_list
    assert_equal(2, @wn_list.length)

    Netki::NetkiPartner.any_instance.unstub(:submit_request)
    Netki::WalletName.any_instance.unstub(:new)
    Netki::WalletName.any_instance.unstub(:set_api_opts)
  end

  def test_get_wallet_names_count_zero

    Netki.expects(:process_request).with('api_key', 'partner_id', 'api_url/v1/partner/walletname?domain_name=domain.com&external_id=ext_id', 'GET').returns({wallet_name_count: 0})
    Netki::WalletName.any_instance.expects(:new).never
    Netki::WalletName.any_instance.expects(:set_api_opts).with('api_url', 'partner_id', 'api_key').never

    @obj = Netki::NetkiPartner.new('partner_id', 'api_key', 'api_url')
    @wn_list = @obj.get_wallet_names('domain.com', 'ext_id')

    assert_not_nil @wn_list
    assert_equal(0, @wn_list.length)

    Netki.unstub(:process_request)
    Netki::WalletName.any_instance.unstub(:new)
    Netki::WalletName.any_instance.unstub(:set_api_opts)

  end

end