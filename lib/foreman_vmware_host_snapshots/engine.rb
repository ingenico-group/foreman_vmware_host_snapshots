require 'deface'

module ForemanVmwareHostSnapshots
  class Engine < ::Rails::Engine
    engine_name 'foreman_vmware_host_snapshots'

    config.autoload_paths += Dir["#{config.root}/app/controllers/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/helpers/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/models/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/overrides"]

    # Add any db migrations
    initializer 'foreman_vmware_host_snapshots.load_app_instance_data' do |app|
      ForemanVmwareHostSnapshots::Engine.paths['db/migrate'].existent.each do |path|
        app.config.paths['db/migrate'] << path
      end
    end

    initializer 'foreman_vmware_host_snapshots.register_plugin', after: :finisher_hook do |_app|
      Foreman::Plugin.register :foreman_vmware_host_snapshots do
        requires_foreman '>= 1.4'

        # Add permissions
        security_block :foreman_vmware_host_snapshots do
          permission :manage_vmware_host_snapshots, :'/hosts/:host_id/vmware_snapshots' => [:index, :show, :create, :revert, :destroy]
        end

        # Add a new role called 'Discovery' if it doesn't exist
        role 'VmwareHostSnapshots', [:manage_vmware_host_snapshots]
        
      end
    end

    # Precompile any JS or CSS files under app/assets/
    # If requiring files from each other, list them explicitly here to avoid precompiling the same
    # content twice.
    assets_to_precompile =
      Dir.chdir(root) do
        Dir['app/assets/javascripts/**/*', 'app/assets/stylesheets/**/*'].map do |f|
          f.split(File::SEPARATOR, 4).last
        end
      end
    initializer 'foreman_vmware_host_snapshots.assets.precompile' do |app|
      app.config.assets.precompile += assets_to_precompile
    end
    initializer 'foreman_vmware_host_snapshots.configure_assets', group: :assets do
      SETTINGS[:foreman_vmware_host_snapshots] = { assets: { precompile: assets_to_precompile } }
    end

    # Include concerns in this config.to_prepare block
    config.to_prepare do
      
        Host::Managed.send(:include, ForemanVmwareHostSnapshots::HostSnapshotMethods)
        Foreman::Model::Vmware.send(:include, ForemanVmwareHostSnapshots::VmwareSnapshotMethods)
      
    end

    rake_tasks do
      Rake::Task['db:seed'].enhance do
        ForemanVmwareHostSnapshots::Engine.load_seed
      end
    end

    initializer 'foreman_vmware_host_snapshots.register_gettext', after: :load_config_initializers do |_app|
      locale_dir = File.join(File.expand_path('../../..', __FILE__), 'locale')
      locale_domain = 'foreman_vmware_host_snapshots'
      Foreman::Gettext::Support.add_text_domain locale_domain, locale_dir
    end
  end
end
