require 'ostruct'

class Foo < OpenStackObject::Server
  attributes :foo, :bar
  methods :baz

  def call_service_method
    service_method do |s|
      return s.a_service_method
    end
  end

  def self.conn
    s = OpenStruct.new(id: 'foo')
    OpenStruct.new(:servers => Servers.new([s, s, s]))
  end
end

class Servers < Array
  def get(id)
    self.select{|e| e.id == id}.first
  end
  def create(params) ; end
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

module OpenStack
  class Role
    def self.all
      [OpenStruct.new(:name => '_member_', :id => 'foo')]
    end
  end
end
