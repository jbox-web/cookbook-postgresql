# Install PGBouncer
package 'pgbouncer'

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
