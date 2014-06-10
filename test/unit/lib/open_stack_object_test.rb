require 'test_helper'

class TestOpenStackObject < Minitest::Test
  def setup
    @foo = Foo.new(Mock.new)
  end

  def test_object_has_attributes_and_methods
    [:foo, :bar, :baz].each do |sym|
      assert @foo.respond_to? sym
    end
  end

  def test_object_delegates_calls_to_contained_object
    assert_equal @foo.bar, 'test'
  end

  def test_contained_object_id_used_as_id
    assert_equal @foo.id, 'mock_id'
  end

  def test_service_method
    assert_equal @foo.call_service_method, 'service!'   
  end

  def test_api_error_message
    assert_equal 'Error!', @foo.send(:api_error_message, MockError.new)
  end

end

class Foo < OpenStackObject::Server
  attributes :foo, :bar
  methods :baz

  def call_service_method
    service_method do |s|
      return s.a_service_method
    end
  end
end

class Mock
  def id
    "mock_id"
  end

  def foo
    'test'
  end

  def bar
    'test'
  end

  def baz
    'test'
  end

  def service
    MockService.new
  end
end

class MockService ; def a_service_method ; 'service!' ; end ; end

class MockError
  def response
    MockResponse.new
  end
end

class MockResponse
  def data
    {body: {'conflictingRequest' => {'message' => 'Error!'}}.to_json}
  end
end