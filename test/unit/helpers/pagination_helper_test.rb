require 'test_helper'
require 'kaminari'

class KaminariArray < Array
  def total_pages  ; 1 ; end
  def current_page ; 1 ; end
  def limit_value  ; 1 ; end
end

module PaginationHelperTests
  class TestModel
    include Kaminari::ActionViewExtension
    include Kaminari::Helpers
    include PaginationHelper

    def render(args)
      @mock.called
    end

    def initialize(mock)
      @mock = mock
    end
  end

  class PaginationHelperTest < CleanTest
    def setup
      @mock = Minitest::Mock.new
      @model = TestModel.new(@mock)
    end

    def test_pagination
      @mock.expect(:called, nil, [])
      @model.pagination(KaminariArray.new)
      @mock.verify
    end

  end
end