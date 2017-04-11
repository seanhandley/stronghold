require 'test_helper'

class UserDecoratorTest < CleanTest
  def setup
    @user = UserDecorator.new(User.make!)
    Authorization.current_organization = @user.primary_organization
  end

  def test_as_sirportly_data
    expected = {
      :reference => @user.id,
      :contact_methods => {
        :email => [@user.email]
      },
      :first_name => @user.first_name,
      :last_name  => @user.last_name,
      :company    => @user.primary_organization.reference,
      :timezone   => @user.primary_organization.time_zone
    }
    assert_equal expected, @user.as_sirportly_data
  end

end
