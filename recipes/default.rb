# Install GPG
package 'dirmngr'

# Install compilation tools to build pg gem
package 'build-essential'

# Install Postgresql repository
apt_repository 'stretch-postgresql-binary' do
  uri          'http://apt.postgresql.org/pub/repos/apt'
  key          'https://www.postgresql.org/media/keys/ACCC4CF8.asc'
  components   [9.6]
  distribution 'stretch-pgdg'
end

# Install Postgresql
package 'postgresql-9.6'

# Install Postgresql dev package
package 'libpq-dev'

# Install PGBouncer
package 'pgbouncer'

# Install Ruby pg gem to create DB
chef_gem 'pg'

# Copy original Postgresql config
cookbook_file '/etc/postgresql/9.6/main/postgresql.conf.orig' do
  source 'postgresql.conf'
  owner  'postgres'
  group  'postgres'
end

# Setup Postgresql data directory
service 'postgresql' do
  action  :stop
  only_if { !Dir.exist?(node[:postgres][:postgres_conf][:data_directory]) }
end

template '/etc/postgresql/9.6/main/postgresql.conf' do
  source    'postgresql.conf.erb'
  variables config: node[:postgres][:postgres_conf]
  owner     'postgres'
  group     'postgres'
  only_if   { !Dir.exist?(node[:postgres][:postgres_conf][:data_directory]) }
end

execute 'pg_dropcluster --stop 9.6 main' do
  command 'pg_dropcluster --stop 9.6 main'
  only_if { !Dir.exist?(node[:postgres][:postgres_conf][:data_directory]) }
end

execute "pg_createcluster -d #{node[:postgres][:postgres_conf][:data_directory]} 9.6 main" do
  command "pg_createcluster -d #{node[:postgres][:postgres_conf][:data_directory]} 9.6 main"
  only_if { !Dir.exist?(node[:postgres][:postgres_conf][:data_directory]) }
end

service 'postgresql' do
  action  :start
  only_if { !Dir.exist?(node[:postgres][:postgres_conf][:data_directory]) }
end

# Install Postgresql config
template '/etc/postgresql/9.6/main/postgresql.conf' do
  source    'postgresql.conf.erb'
  variables config: node[:postgres][:postgres_conf]
  owner     'postgres'
  group     'postgres'
end

template '/etc/postgresql/9.6/main/pg_hba.conf' do
  source    'pg_hba.conf.erb'
  variables config: node[:postgres][:pg_hba]
  owner     'postgres'
  group     'postgres'
  mode      '0640'
end

# Restart Postgresql when config is changed
service 'postgresql' do
  subscribes :restart, 'template[/etc/postgresql/9.6/main/postgresql.conf]', :immediately
  subscribes :restart, 'template[/etc/postgresql/9.6/main/pg_hba.conf]', :immediately
end

# Copy original PGBouncer config
cookbook_file '/etc/pgbouncer/pgbouncer.ini.orig' do
  source 'pgbouncer.ini'
  owner  'postgres'
  group  'postgres'
  mode   '0640'
end

# Install PGBouncer config
template '/etc/pgbouncer/pgbouncer.ini' do
  source    'pgbouncer.ini.erb'
  variables config: node[:pgbouncer][:config]
  owner     'postgres'
  group     'postgres'
  mode      '0640'
end

# Restart PGBouncer when config is changed
service 'pgbouncer' do
  subscribes :restart, 'template[/etc/pgbouncer/pgbouncer.ini]', :delayed
end
