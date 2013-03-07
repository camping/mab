require 'rake/testtask'

task :default => :test
task :test => 'test:core'

namespace 'test' do
  Rake::TestTask.new('core') do |t|
    t.libs << 'lib' << 'test'
  end

  Rake::TestTask.new('rails') do |t|
    t.libs << 'lib'
    t.test_files = FileList['test/rails/test/test_*.rb']
  end
end

