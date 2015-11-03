require 'test_helper'

class TestModel
  include StatusIoHelper
end

class StatusIoHelperTest < CleanTest
  def setup
    @model = TestModel.new
  end

  def test_status_io_url
    dummy = OpenStruct.new(secrets: OpenStruct.new(status_io_page_id: 'foo'))
    Rails.stub(:application, dummy) do
      assert_equal "http://status.datacentred.io/pages/baz/foo/bar",
                   @model.status_io_url('baz', 'bar')
    end
  end

end