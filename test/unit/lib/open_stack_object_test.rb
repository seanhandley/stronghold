require 'test_helper'
require_relative '../../support/open_stack_mocks'

class TestOpenStackObject < CleanTest
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

  def test_method_all_wraps_results
    Foo.all.each{|f| assert f.class.to_s == 'Foo'}
  end

  def test_method_find_all_by_wraps_results
    Foo.find_all_by(:id, 'foo').each{|f| assert f.class.to_s == 'Foo'}
  end

  def test_method_find_by_all_returns_empty_if_not_found
    assert_equal [], Foo.find_all_by(:id, 'bar')
  end

  def test_method_hands_off_to_get
    assert_equal 'foo', Foo.find('foo').id
  end

  def test_method_find_returns_nil_if_not_found
    refute Foo.find('bar')
  end

  def test_method_create_returns_a_foo
    assert_equal 'Foo', Foo.create(name: 'foo').class.to_s
  end

end