resource_name :postgres_cluster
provides :postgres_cluster
unified_mode true

property :data_dir, String, name_property: true
property :version,  String, name_property: true
property :encoding, String, default: 'UTF8'
property :locale,   String, default: 'en_US.UTF-8'

action :install do
  execute "pg_createcluster -e #{new_resource.encoding} --locale #{new_resource.locale} -d #{new_resource.data_dir} #{new_resource.version} main" do
    notifies :restart, 'service[postgresql]', :immediately
    only_if { !Dir.exist?(new_resource.data_dir) }
  end
end

action :remove do
  execute "pg_dropcluster --stop #{new_resource.version} main" do
    only_if { !Dir.exist?(new_resource.data_dir) }
  end
end
