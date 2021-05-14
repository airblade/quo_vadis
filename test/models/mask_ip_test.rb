require 'test_helper'

class MaskIpTest < ActiveSupport::TestCase

  setup do
    @masking = QuoVadis.mask_ips
  end

  teardown do
    QuoVadis.mask_ips @masking
  end


  test 'mask ips' do
    [ QuoVadis::Log, QuoVadis::Session ].each do |klass|
      QuoVadis.mask_ips false
      instance = klass.new(ip: '1.2.3.4')
      instance.valid?
      assert_equal '1.2.3.4', instance.ip

      QuoVadis.mask_ips true
      instance.valid?
      assert_equal '1.2.3.0', instance.ip
    end
  end

end
