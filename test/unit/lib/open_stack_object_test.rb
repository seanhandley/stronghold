require 'test_helper'

class Foo < OpenStackObject::Server
  attributes :foo, :bar
  methods :baz
end

class Mock

  def id
    "mock_id"
  end

  def bar
    'test'
  end
end

class TestOpenStackObject < Minitest::Test
  def setup
    @params = {name: 'Foo'}
    @foo = Foo.new(@params)
  end

  def test_object_has_attributes_and_methods
    [:foo, :bar, :baz].each do |sym|
      assert @foo.respond_to? sym
    end
  end

  def test_object_delegates_calls_to_contained_object
    OpenStackObject::Base.stub :new, Mock.new do
      assert_equal Foo.new(@params).bar, 'test'
    end
  end

  def test_contained_object_id_used_as_id
    OpenStackObject::Base.stub :new, Mock.new do
      assert_equal Foo.new(@params).id, 'mock_id'
    end  
  end

end