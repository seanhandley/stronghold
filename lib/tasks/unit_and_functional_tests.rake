# Define the task for running acceptance tests
Rake::TestTask.new do |t|
  t.libs = ["lib", "test"]
  t.name = "test:unit_and_functional"
  t.test_files = FileList['test/unit/**/*_test.rb', 'test/functional/**/*_test.rb']
end   