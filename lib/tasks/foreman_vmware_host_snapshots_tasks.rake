# Tasks
namespace :foreman_vmware_host_snapshots do
  namespace :example do
    desc 'Example Task'
    task task: :environment do
      # Task goes here
    end
  end
end

# Tests
namespace :test do
  desc 'Test ForemanVmwareHostSnapshots'
  Rake::TestTask.new(:foreman_vmware_host_snapshots) do |t|
    test_dir = File.join(File.dirname(__FILE__), '../..', 'test')
    t.libs << ['test', test_dir]
    t.pattern = "#{test_dir}/**/*_test.rb"
    t.verbose = true
  end
end

namespace :foreman_vmware_host_snapshots do
  task :rubocop do
    begin
      require 'rubocop/rake_task'
      RuboCop::RakeTask.new(:rubocop_foreman_vmware_host_snapshots) do |task|
        task.patterns = ["#{ForemanVmwareHostSnapshots::Engine.root}/app/**/*.rb",
                         "#{ForemanVmwareHostSnapshots::Engine.root}/lib/**/*.rb",
                         "#{ForemanVmwareHostSnapshots::Engine.root}/test/**/*.rb"]
      end
    rescue
      puts 'Rubocop not loaded.'
    end

    Rake::Task['rubocop_foreman_vmware_host_snapshots'].invoke
  end
end

Rake::Task[:test].enhance do
  Rake::Task['test:foreman_vmware_host_snapshots'].invoke
end

load 'tasks/jenkins.rake'
if Rake::Task.task_defined?(:'jenkins:unit')
  Rake::Task['jenkins:unit'].enhance do
    Rake::Task['test:foreman_vmware_host_snapshots'].invoke
    Rake::Task['foreman_vmware_host_snapshots:rubocop'].invoke
  end
end
