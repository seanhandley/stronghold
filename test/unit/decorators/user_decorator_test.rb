require 'test_helper'

class UserDecoratorTest < CleanTest
  def setup
    @user = UserDecorator.new(User.make!)
  end

  def test_as_sirportly_data
    expected = {
      :reference => @user.unique_id,
      :contact_methods => {
        :email => [@user.email]
      },
      :first_name => @user.first_name,
      :last_name  => @user.last_name,
      :company    => @user.organizations.first.reference,
      :timezone   => @user.organizations.first.time_zone
    }
    assert_equal expected, @user.as_sirportly_data
  end

end