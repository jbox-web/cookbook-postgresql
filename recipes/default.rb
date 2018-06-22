version  = node[:postgres][:version]
data_dir = node[:postgres][:postgres_conf][:data_directory] % { version: version }

# Install GPG
package 'dirmngr'

# Install compilation tools to build pg gem
package 'build-essential'

# Install Postgresql repository
apt_repository 'stretch-postgresql-binary' do
  uri          'http://apt.postgresql.org/pub/repos/apt'
  key          'https://www.postgresql.org/media/keys/ACCC4CF8.asc'
  components   [(version.to_s == '10' ? 'main' : version)]
  distribution 'stretch-pgdg'
end

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

execute "pg_dropcluster --stop #{version} main" do
  only_if { !Dir.exist?(data_dir) }
end

execute "pg_createcluster -d #{data_dir} #{version} main" do
  only_if { !Dir.exist?(data_dir) }
end

service 'postgresql' do
  action  :start
  only_if { !Dir.exist?(data_dir) }
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

# Restart Postgresql when config is changed
service 'postgresql' do
  subscribes :restart, "template[/etc/postgresql/#{version}/main/postgresql.conf]", :immediately
  subscribes :restart, "template[/etc/postgresql/#{version}/main/pg_hba.conf]", :immediately
end
