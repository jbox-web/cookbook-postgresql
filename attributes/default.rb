# Default Postgresql config
default['postgres']['version'] = '12'

# postgresql.conf :
default['postgres']['postgres_conf']['data_directory']             = "/var/lib/postgresql/%{version}/main"
default['postgres']['postgres_conf']['hba_file']                   = "/etc/postgresql/%{version}/main/pg_hba.conf"
default['postgres']['postgres_conf']['ident_file']                 = "/etc/postgresql/%{version}/main/pg_ident.conf"
default['postgres']['postgres_conf']['unix_socket_directories']    = '/var/run/postgresql'
default['postgres']['postgres_conf']['external_pid_file']          = "/var/run/postgresql/%{version}-main.pid"
default['postgres']['postgres_conf']['stats_temp_directory']       = "/var/run/postgresql/%{version}-main.pg_stat_tmp"
default['postgres']['postgres_conf']['cluster_name']               = "%{version}/main"
default['postgres']['postgres_conf']['listen_addresses']           = '127.0.0.1'
default['postgres']['postgres_conf']['port']                       = 5432
default['postgres']['postgres_conf']['ssl']                        = true
default['postgres']['postgres_conf']['ssl_cert_file']              = '/etc/ssl/certs/ssl-cert-snakeoil.pem'
default['postgres']['postgres_conf']['ssl_key_file']               = '/etc/ssl/private/ssl-cert-snakeoil.key'
default['postgres']['postgres_conf']['max_connections']            = 100
default['postgres']['postgres_conf']['shared_buffers']             = '128MB'
default['postgres']['postgres_conf']['dynamic_shared_memory_type'] = 'posix'
default['postgres']['postgres_conf']['log_line_prefix']            = '%t [%p-%l] %q%u@%d '
default['postgres']['postgres_conf']['log_timezone']               = 'localtime'
default['postgres']['postgres_conf']['datestyle']                  = 'iso, mdy'
default['postgres']['postgres_conf']['timezone']                   = 'localtime'
default['postgres']['postgres_conf']['lc_messages']                = 'C.UTF-8'
default['postgres']['postgres_conf']['lc_monetary']                = 'C.UTF-8'
default['postgres']['postgres_conf']['lc_numeric']                 = 'C.UTF-8'
default['postgres']['postgres_conf']['lc_time']                    = 'C.UTF-8'
default['postgres']['postgres_conf']['default_text_search_config'] = 'pg_catalog.english'

# pg_hba.conf :
default['postgres']['pg_hba'] = [
  ['local', 'all', 'postgres', '',             'trust'],
  ['local', 'all', 'all',      '',             'peer'],
  ['host',  'all', 'all',      '127.0.0.1/32', 'md5'],
  ['host',  'all', 'all',      '::1/128',      'md5'],
]

# Default PGBouncer config
default['pgbouncer']['config']['databases']                       = {}
default['pgbouncer']['config']['pgbouncer']                       = {}
default['pgbouncer']['config']['pgbouncer']['logfile']            = '/var/log/postgresql/pgbouncer.log'
default['pgbouncer']['config']['pgbouncer']['pidfile']            = '/var/run/postgresql/pgbouncer.pid'
default['pgbouncer']['config']['pgbouncer']['listen_addr']        = '127.0.0.1'
default['pgbouncer']['config']['pgbouncer']['listen_port']        = 6432
default['pgbouncer']['config']['pgbouncer']['unix_socket_dir']    = '/var/run/postgresql'
default['pgbouncer']['config']['pgbouncer']['auth_type']          = 'trust'
default['pgbouncer']['config']['pgbouncer']['auth_file']          = '/etc/pgbouncer/userlist.txt'
default['pgbouncer']['config']['pgbouncer']['pool_mode']          = 'session'
default['pgbouncer']['config']['pgbouncer']['server_reset_query'] = 'DISCARD ALL'
default['pgbouncer']['config']['pgbouncer']['max_client_conn']    = 100
default['pgbouncer']['config']['pgbouncer']['default_pool_size']  = 20

# Default AutoPostgreSQLBackup config
default['autopostgresqlbackup']['config']['su_username']           = 'postgres'
default['autopostgresqlbackup']['config']['username']              = 'postgres'
default['autopostgresqlbackup']['config']['dbhost']                = 'localhost'
default['autopostgresqlbackup']['config']['dbnames']               = 'all'
default['autopostgresqlbackup']['config']['globals_objects']       = 'postgres_globals'
default['autopostgresqlbackup']['config']['backupdir']             = '/var/backups/postgresql'
default['autopostgresqlbackup']['config']['mailcontent']           = 'log'
default['autopostgresqlbackup']['config']['maxattsize']            = '4000'
default['autopostgresqlbackup']['config']['mailaddr']              = 'root'
default['autopostgresqlbackup']['config']['mdbnames']              = 'template1 $DBNAMES'
default['autopostgresqlbackup']['config']['dbexclude']             = ''
default['autopostgresqlbackup']['config']['create_database']       = 'no'
default['autopostgresqlbackup']['config']['sepdir']                = 'yes'
default['autopostgresqlbackup']['config']['doweekly']              = 6
default['autopostgresqlbackup']['config']['comp']                  = 'gzip'
default['autopostgresqlbackup']['config']['commcomp']              = 0
default['autopostgresqlbackup']['config']['latest']                = 'no'
default['autopostgresqlbackup']['config']['opt']                   = ''
default['autopostgresqlbackup']['config']['ext']                   = 'sql'
default['autopostgresqlbackup']['config']['perm']                  = 600
default['autopostgresqlbackup']['config']['encryption']            = 'no'
default['autopostgresqlbackup']['config']['encryption_public_key'] = '/etc/ssl/certs/autopostgresqlbackup.crt'
default['autopostgresqlbackup']['config']['encryption_cipher']     = 'aes256'
default['autopostgresqlbackup']['config']['encryption_suffix']     = '.enc'
