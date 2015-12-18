require File.expand_path('../lib/foreman_vmware_host_snapshots/version', __FILE__)
# require 'date'

Gem::Specification.new do |s|
  s.name        = 'foreman_vmware_host_snapshots'
  s.version     = ForemanVmwareHostSnapshots::VERSION
  # s.date        = Date.today.to_s
  s.authors     = ['Nagarjuna Rachaneni']
  s.email       = ['nagarjuna.r@indecomm.net']
  s.homepage    = 'https://gitlab.sys.lab.ingenico.com/sys/foreman_vmware_host_snapshots'
  s.summary     = 'Provide snapshot management to VMWare hosts'
  # also update locale/gemspec.rb
  s.description = 'Provide snapshot management to VMWare hosts'

  s.files = Dir['{app,config,lib,locale}/**/*'] + ['LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'deface'
end
