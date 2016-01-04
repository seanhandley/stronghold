# Define the task for running acceptance tests
Rake::TestTask.new do |t|
  t.libs = ["lib", "test"]
  t.name = "test:acceptance"
  t.test_files = FileList['test/acceptance/**/*_test.rb']
end   