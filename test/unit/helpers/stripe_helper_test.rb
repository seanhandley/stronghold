require 'test_helper'

class TestModel
  include StripeHelper

  def raise_error(error, handler)
    rescue_stripe_errors(handler) { raise error }
  end

  class Honeybadger ; def self.notify ; end ; end
end

class StripeHelperTest < CleanTest
  def setup
    @model = TestModel.new
  end

  def test_rescue_errors_card_error
    handler = Minitest::Mock.new
    handler.expect(:call, nil, ['foo'])
    @model.raise_error(Stripe::CardError.new('foo', :bar, 500), handler)
    handler.verify
  end

  def test_rescue_errors_connection_error
    error = Stripe::APIConnectionError.new('foo')
    handler = Minitest::Mock.new
    handler.expect(:call, nil, ["Payment provider isn't responding. Please try again."])

    @model.raise_error(error, handler)
    handler.verify
  end

  def test_rescue_errors_misc_error
    error = Stripe::StripeError.new('foo')
    handler = Minitest::Mock.new
    handler.expect(:call, nil, ["We're sorry - something went wrong. Our tech team has been notified."])

    @model.raise_error(error, handler)
    handler.verify
  end

  def test_rescue_errors_unrelated_error
    error = ArgumentError.new('foo')
    handler = lambda {}
    assert_raises ArgumentError do
      @model.raise_error(error, handler)
    end
  end

  class DummyCustomer
    class Sources
      def all(params)
        @coll
      end

      def initialize(coll)
        @coll = coll
      end
    end
    def sources
      Sources.new(@coll)
    end

    def initialize(coll=[])
      @coll = coll
    end
  end

  class Card
    def initialize(params)
      @valid = params[:valid]
    end

    def save
      @valid ? true : raise(Stripe::CardError.new('foo', :bar, 500))
    end

    def metadata
      {}
    end
  end

  def test_stripe_has_valid_source_no_cards
    dummy = DummyCustomer.new
    Stripe::Customer.stub(:retrieve, dummy, ['dummy']) do
      refute @model.stripe_has_valid_source?('dummy')
    end
  end

  def test_stripe_has_valid_source_no_valid_cards
    invalid_card = 
    dummy = DummyCustomer.new([Card.new(valid: false)])
    Stripe::Customer.stub(:retrieve, dummy, ['dummy']) do
      refute @model.stripe_has_valid_source?('dummy')
    end
  end

  def test_stripe_has_valid_source_valid_card
    dummy = DummyCustomer.new([Card.new(valid: true), Card.new(valid: false)])
    Stripe::Customer.stub(:retrieve, dummy, ['dummy']) do
      assert @model.stripe_has_valid_source?('dummy')
    end
  end

end