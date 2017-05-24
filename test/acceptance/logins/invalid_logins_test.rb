require_relative '../acceptance_test_helper'

class InvalidLoginsTests < CapybaraTestCase
  
  def test_valid_login
    visit('/')
    sleep(5)
    within('.page-body') do
      assert has_content?('Last week, you spent')
    end
  end

  def test_invalid_login
    logout
    [
      {u: 'foo', p: ''},
      {u: 'foo@bar.com', p: ''},
      {u: 'foo@bar.com', p: '123'},
      {u: '', p: ''},
      {u: User.first.email, p: '87654321'}
    ].each do |c|
      login(c[:u],c[:p])
      within('#sign-in') do
        assert has_content?('Invalid credentials')
      end 
    end
  end
  
end