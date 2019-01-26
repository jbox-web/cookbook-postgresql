# Include main recipe (install apt repo)
include_recipe 'postgresql'

# Get current version
version  = node[:postgres][:version]
data_dir = node[:postgres][:postgres_conf][:data_directory] % { version: version }

# Install Postgresql
package "postgresql-#{version}"

# Install Postgresql dev package
package 'libpq-dev'

# Install Ruby pg gem to create DB
chef_gem 'pg'

# Copy original Postgresql config
cookbook_file "/etc/postgresql/#{version}/main/postgresql.conf.orig" do
  source 'postgresql.conf'
  owner  'postgres'
  group  'postgres'
end

# Setup Postgresql data directory
service 'postgresql' do
  action  :stop
  only_if { !Dir.exist?(data_dir) }
end

template "/etc/postgresql/#{version}/main/postgresql.conf" do
  source    'postgresql.conf.erb'
  variables config: node[:postgres][:postgres_conf]
  owner     'postgres'
  group     'postgres'
  only_if   { !Dir.exist?(data_dir) }
end

postgres_cluster "Remove cluster '#{version}'" do
  data_dir data_dir
  version  version.to_s
  action   :remove
end

postgres_cluster "Create cluster '#{version}' in '#{data_dir}'" do
  data_dir data_dir
  version  version.to_s
  action   :install
end

# Install Postgresql config
template "/etc/postgresql/#{version}/main/postgresql.conf" do
  source    'postgresql.conf.erb'
  variables config: node[:postgres][:postgres_conf], version: version
  owner     'postgres'
  group     'postgres'
end

template "/etc/postgresql/#{version}/main/pg_hba.conf" do
  source    'pg_hba.conf.erb'
  variables config: node[:postgres][:pg_hba]
  owner     'postgres'
  group     'postgres'
  mode      '0640'
end

# Configure logrotate
cookbook_file '/etc/logrotate.d/postgresql-common' do
  source 'logrotate/postgresql-common'
end

# Create Postgresql log archive dir
directory '/var/log/OLD_LOGS/postgresql' do
  recursive true
end

# Restart Postgresql when config is changed
service 'postgresql' do
  subscribes :restart, "template[/etc/postgresql/#{version}/main/postgresql.conf]", :immediately
  subscribes :restart, "template[/etc/postgresql/#{version}/main/pg_hba.conf]", :immediately
end
