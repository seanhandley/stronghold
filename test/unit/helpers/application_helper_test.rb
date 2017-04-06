require 'test_helper'

module ApplicationHelperTests

  class TestModel
    include ApplicationHelper

    def initialize(flash) ; @flash = flash ; end
    def flash ; @flash ; end
    attr_accessor :output_buffer

    def content_for(sym, &blk) ; end

    def view_flow
      @view_flow ||= ActionView::OutputFlow.new
    end
  end

  class ApplicationHelperTest < CleanTest
    def setup
      @flash = {
        'alert' => "Gordon's alive!"
      }
      @model = TestModel.new(@flash)
    end

    def test_display_flash
      assert_equal "<div class=\"alert alert-danger\"><p>Gordon&#39;s alive!</p></div>", @model.display_flash
    end

    def test_javascript_error_messages_for
      obj = OpenStruct.new(id: 1)
      assert_equal "<div id=\"js_errors\" class=\"hide alert alert-danger errors1\"></div>", @model.javascript_error_messages_for(obj)
    end

    def test_javascript_success_messages_for
      obj = OpenStruct.new(id: 1)
      assert_equal "<div id=\"js_successes\" class=\"hide alert alert-success success1\"></div>", @model.javascript_success_messages_for(obj)
    end

    def test_title
      @model.title("Gordon's alive!")
    end

    def test_get_model_errors
      errors = OpenStruct.new(errors: OpenStruct.new(messages: {"name" => "is wrong"}))
      assert_equal [{"field"=>"name", "message"=>"i"}], @model.get_model_errors(errors)
    end

    def test_flash_key_to_bootstrap_class
      [
        {k: 'error', v: 'danger'},
        {k: 'alert', v: 'danger'},
        {k: 'notice', v: 'info'}
      ].each do |h|
        assert_equal h[:v], @model.flash_key_to_bootstrap_class(h[:k])
      end
    end

  end
end
