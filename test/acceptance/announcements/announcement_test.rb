# require_relative '../acceptance_test_helper'

# class AnnouncementTests < CapybaraTestCase

#   def setup
#     User.first.organization.products = [Product.first, Product.second, Product.third]
#     login
#     visit(admin_utilities_announcements_path)
#   end

#   def create_announcement(params={})
#     title      = params[:title] || Faker::Lorem.words(3).join
#     body       = params[:body]  || Faker::Lorem.words(3).join
#     start_date = params[:start_date]
#     stop_date  = params[:stop_date]
#     start_time = params[:start_time]
#     stop_time  = params[:stop_time]
#     filters    = params[:filters] || []

#     click_button "New Announcement"
#     within('.modal-content') do
#       fill_in('title', :with => title)
#       fill_in('body', :with => body)
#       fill_in('start-date', with: start_date)
#       fill_in('stop-date', with: stop_date)
#       fill_in('start-time', with: start_time)
#       fill_in('stop-time', with: stop_time)
#       filters.each {|filter| check filter}
#       click_button('Create')
#     end
#     sleep 1
#     [title, body, start_date, stop_date, start_time, stop_time, filters]
#   end

#   def test_user_can_create_new_announcement
#     title, body = create_announcement

#     within('body') do
#       assert has_content?('Announcement created successfully')
#     end
#     visit('/')
#     within('body') do
#       assert has_content?(title)
#       assert has_content?(body)
#     end
#   end

#   def test_announcement_can_be_deactivated
#     title, body = create_announcement

#     announcement = Starburst::Announcement.last

#     within('body') do
#       assert has_content?(title)
#     end

#     click_link("deactivate_btn#{announcement.id}")

#     within('body') do
#       assert has_content?('Successfully deactivated')
#     end
#     visit(admin_utilities_announcements_path)
#     within('body') do
#       refute has_content?(title)
#       refute has_content?(body)
#     end
#   end

#   def test_announcement_can_be_scheduled
#     year = Time.now.year + 1
#     title, body = create_announcement(start_date: "21/04/#{year}", stop_date: "21/06/#{year}",
#                                       start_time: "23:00",         stop_time: "23:00")

#     Timecop.freeze(Time.local(year, 5, 21)) do
#       visit('/')
#       login
#       sleep 1
#       within('body') do
#         assert has_content?(title)
#         assert has_content?(body)
#       end
#     end

#     Timecop.freeze(Time.local(year+1, 5, 21)) do
#       visit('/')
#       login
#       sleep 1
#       within('body') do
#         refute has_content?(title)
#         refute has_content?(body)
#       end
#     end
#     Timecop.return
#   end

#   def test_limit_announcements_to_admin_users
#     title, body = create_announcement filters: ['filters_admin_']
#     User.first.roles.first.update_attributes power_user: false
#     sleep 2
#     visit('/')

#     within('body') do
#       refute has_content?(title)
#     end
#     User.first.roles.first.update_attributes power_user: true
#   end

#   def test_limit_announcements_to_compute_users
#     title, body = create_announcement filters: ['filters_compute_']
#     User.first.organization.update_attributes products: [Product.find_by_name("Storage")]
#     sleep 2

#     visit('/')

#     within('body') do
#       refute has_content?(title)
#     end

#     User.first.organization.update_attributes products: [Product.find_by_name("Compute")]
#     sleep 2

#     visit('/')

#     within('body') do
#       assert has_content?(title)
#     end
#   end

#   def test_limit_announcements_to_storage_users
#     title, body = create_announcement filters: ['filters_storage_']
#     User.first.organization.update_attributes products: [Product.find_by_name("Compute")]
#     sleep 2

#     visit('/')

#     within('body') do
#       refute has_content?(title)
#     end

#     User.first.organization.update_attributes products: [Product.find_by_name("Storage")]
#     sleep 2

#     visit('/')

#     within('body') do
#       assert has_content?(title)
#     end
#   end

#   def test_limit_announcements_to_colocation_users
#     title, body = create_announcement filters: ['filters_colo_']
#     User.first.organization.update_attributes products: [Product.find_by_name("Storage")]
#     sleep 2

#     visit('/')

#     within('body') do
#       refute has_content?(title)
#     end

#     User.first.organization.update_attributes products: [Product.find_by_name("Colocation")]
#     sleep 2

#     visit('/')

#     within('body') do
#       assert has_content?(title)
#     end
#   end

#   def teardown
#     Starburst::Announcement.destroy_all
#     Starburst::AnnouncementView.destroy_all
#     User.first.organization.products.destroy_all
#     User.first.organization.products = [Product.first, Product.second, Product.third]
#     logout
#   end
# end
