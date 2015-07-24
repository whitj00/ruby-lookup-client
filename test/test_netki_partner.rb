require 'test/unit'
require 'mocha/test_unit'
require 'webmock/test_unit'
require_relative '../lib/netki/netki'

class TestCreatePartner < Test::Unit::TestCase

  def setup
    @resp_data = {
        "success" => true,
        "partner" => {
            "id" => 'new_partner_id',
            "name" => 'Test Partner'
        }
    }
  end

  def test_go_right

    # Setup Data
    Netki.expects(:process_request).with('api_key', 'partner_id', 'api_url/v1/admin/partner/Test%20Partner', 'POST').returns(@resp_data)

    # Create Netki Object and Call Tested Method
    @obj = Netki::NetkiPartner.new('partner_id', 'api_key', 'api_url')
    ret_val = @obj.create_new_partner('Test Partner')

    # Asserts
    assert_equal('new_partner_id', ret_val)

    # Unstub
    Netki.unstub(:process_request)

  end
end

class TestGetPartners < Test::Unit::TestCase

  def setup
    @resp_data = {
        "success" =>  true,
        "partners" =>  [{
            "id" =>  'new_partner_id',
            "name" =>  'Test Partner'
        }]
    }
  end

  def test_go_right

    # Setup Data
    Netki.expects(:process_request).with('api_key', 'partner_id', 'api_url/v1/admin/partner', 'GET').returns(@resp_data)

    # Create Netki Object and Call Tested Method
    @obj = Netki::NetkiPartner.new('partner_id', 'api_key', 'api_url')
    ret_val = @obj.get_partners

    # Asserts
    assert_equal([{"id" => 'new_partner_id', "name" => 'Test Partner'}], ret_val)

    # Unstub
    Netki.unstub(:process_request)

  end

end

class TestDeletePartner < Test::Unit::TestCase

  def setup
    @resp_data = {
        "success" =>  false,
        "message" =>  'Error Message'
    }
  end

  def test_go_right

    # Setup Data
    Netki.expects(:process_request).with('api_key', 'partner_id', 'api_url/v1/admin/partner/Test%20Partner', 'DELETE').returns(@resp_data)

    # Create Netki Object and Call Tested Method
    @obj = Netki::NetkiPartner.new('partner_id', 'api_key', 'api_url')
    @obj.delete_partner('Test Partner')

    # Asserts
    assert_true(true)

    # Unstub
    Netki.unstub(:process_request)

  end
end

class TestCreateDomain < Test::Unit::TestCase

  def setup
    @resp_data = {
        "success" =>  true
    }
  end

  def test_go_right_no_partner_id

    # Setup Data
    Netki.expects(:process_request).with('api_key', 'partner_id', 'api_url/v1/partner/domain/domain.com', 'POST', '{}').returns(@resp_data)

    # Create Netki Object and Call Tested Method
    @obj = Netki::NetkiPartner.new('partner_id', 'api_key', 'api_url')
    ret_val = @obj.create_new_domain('domain.com')

    # Asserts
    assert_true(ret_val)

    # Unstub
    Netki.unstub(:process_request)

  end

  def test_go_right_with_partner_id

    # Setup Data
    Netki.expects(:process_request).with('api_key', 'partner_id', 'api_url/v1/partner/domain/domain.com', 'POST', '{"partner_id":"sub_partner_id"}').returns(@resp_data)

    # Create Netki Object and Call Tested Method
    @obj = Netki::NetkiPartner.new('partner_id', 'api_key', 'api_url')
    ret_val = @obj.create_new_domain('domain.com', 'sub_partner_id')

    # Asserts
    assert_true(ret_val)

    # Unstub
    Netki.unstub(:process_request)

  end
end

class TestGetDomains < Test::Unit::TestCase

  def setup
    @resp_data = {
        "success" =>  true,
        "domains" =>  [{
                       "domain_name" =>  'domain.com'
                   }]
    }


  end

  def test_go_right

    # Setup Data
    Netki.expects(:process_request).with('api_key', 'partner_id', 'api_url/api/domain', 'GET').returns(@resp_data)

    # Create Netki Object and Call Tested Method
    @obj = Netki::NetkiPartner.new('partner_id', 'api_key', 'api_url')
    ret_val = @obj.get_domains

    # Asserts
    assert_equal([{"domain_name" => 'domain.com'}], ret_val)

    # Unstub
    Netki.unstub(:process_request)

  end
end

class TestGetDomainStatus < Test::Unit::TestCase

  def setup
    @resp_data = {
        "success" =>  true,
        "domains" =>  [{
                      "domain_name" =>  'domain.com',
                      "status" =>  'OK'
                  }]
    }
  end

  def test_go_right_empty_domain_arg

    # Setup Data
    Netki.expects(:process_request).with('api_key', 'partner_id', 'api_url/v1/partner/domain', 'GET').returns(@resp_data)

    # Create Netki Object and Call Tested Method
    @obj = Netki::NetkiPartner.new('partner_id', 'api_key', 'api_url')
    ret_val = @obj.get_domain_status

    # Asserts
    assert_equal([{"domain_name" => 'domain.com', "status" => "OK"}], ret_val)

    # Unstub
    Netki.unstub(:process_request)

  end

  def test_go_right_with_domain

    # Setup Data
    Netki.expects(:process_request).with('api_key', 'partner_id', 'api_url/v1/partner/domain/domain.com', 'GET').returns(@resp_data)

    # Create Netki Object and Call Tested Method
    @obj = Netki::NetkiPartner.new('partner_id', 'api_key', 'api_url')
    ret_val = @obj.get_domain_status('domain.com')

    # Asserts
    assert_equal([{"domain_name" => 'domain.com', "status" => "OK"}], ret_val)

    # Unstub
    Netki.unstub(:process_request)

  end
end

class TestGetDomainDnssec < Test::Unit::TestCase

  def setup
    @resp_data = {
        "success" =>  true
    }
  end

  def test_go_right

    # Setup Data
    Netki.expects(:process_request).with('api_key', 'partner_id', 'api_url/v1/partner/domain/dnssec/domain.com', 'GET').returns(@resp_data)

    # Create Netki Object and Call Tested Method
    @obj = Netki::NetkiPartner.new('partner_id', 'api_key', 'api_url')
    ret_val = @obj.get_domain_dnssec('domain.com')

    # Asserts
    assert_equal({"success" => true}, ret_val)

    # Unstub
    Netki.unstub(:process_request)

  end
end

class TestDeleteDomain < Test::Unit::TestCase

  def setup
    @resp_data = {
        "success" =>  true
    }
  end

  def test_go_right

    # Setup Data
    Netki.expects(:process_request).with('api_key', 'partner_id', 'api_url/v1/partner/domain/domain.com', 'DELETE').returns(@resp_data)

    # Create Netki Object and Call Tested Method
    @obj = Netki::NetkiPartner.new('partner_id', 'api_key', 'api_url')
    ret_val = @obj.delete_domain('domain.com')

    # Asserts
    assert_true(ret_val)

    # Unstub
    Netki.unstub(:process_request)

  end
end