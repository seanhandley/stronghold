require 'test_helper'
require 'ostruct'

class MockClient
  def Project
    MockProject.new
  end

end

class MockProject
  def find(args)
    OpenStruct.new(:attrs => {'id' => '1'}, :client => OpenStruct.new(:Issue => OpenStruct.new(:build => MockIssue.new)))
  end
end

class MockIssue
  def save(args)
    true
  end

  def key
    '12345'
  end

  def summary
    'blah blah'
  end

  def description
    'some summary'
  end
end

class TestSupportTicket < Minitest::Test
  def setup
    @params = { title: "Test Issue", reference: 'foo123' }
  end

  def test_create_new_issue
    SupportTicket.stub(:client, MockClient.new) do
      support_ticket = SupportTicket.create(@params)
      assert_equal '12345', support_ticket.id
      assert_equal 'blah blah', support_ticket.title
      assert_equal 'some summary', support_ticket.description
      assert support_ticket.is_a? SupportTicket
    end
  end
end