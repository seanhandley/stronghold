Rails::TestTask.new("test:acceptance" => "test:prepare") do |t|
  t.pattern = "test/acceptance/**/*_test.rb"
end