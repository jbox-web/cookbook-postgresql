# Install AutoPostgreSQLBackup
package 'autopostgresqlbackup'

# Create PostgreSQL backup dir
directory node[:autopostgresqlbackup][:config][:backupdir] do
  recursive true
  mode   '0700'
end

# Install /etc/cron.daily/autopostgresqlbackup
cookbook_file '/etc/cron.daily/autopostgresqlbackup' do
  source 'cron/autopostgresqlbackup'
  mode   '0755'
end

# Configure AutoPostgreSQLBackup
template '/etc/default/autopostgresqlbackup' do
  source    'autopostgresqlbackup'
  variables config: node[:autopostgresqlbackup][:config]
end
