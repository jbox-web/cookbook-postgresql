resource_name :postgres_exporter
provides :postgres_exporter

property :auto_discover_databases,  [true, false], default: false
property :constant_labels,          String
property :data_source_name,         String
property :data_source_pass,         [String, Proc]
property :data_source_pass_file,    String
property :data_source_uri,          String
property :data_source_user,         String
property :data_source_user_file,    String
property :disable_default_metrics,  [true, false], default: false
property :disable_settings_metrics, [true, false], default: false
property :extend_query_path,        String
property :instance_name,            String, name_property: true
property :log_format,               String
property :log_level,                String
property :user,                     String, default:       'postgres_exporter'
property :web_listen_address,       String, default:       '0.0.0.0:9187'
property :web_telemetry_path,       String

action :install do
  # Set property that can be queried with Chef search
  node.default['prometheus_exporters']['postgres']['enabled'] = true

  options = "--web.listen-address '#{new_resource.web_listen_address}'"
  options += " --web.telemetry-path '#{new_resource.web_telemetry_path}'" if new_resource.web_telemetry_path
  options += " --log.level #{new_resource.log_level}" if new_resource.log_level
  options += " --log.format '#{new_resource.log_format}'" if new_resource.log_format
  options += " --extend.query-path #{new_resource.extend_query_path}" if new_resource.extend_query_path
  options += ' --disable-default-metrics' if new_resource.disable_default_metrics
  options += ' --disable-settings-metrics' if new_resource.disable_settings_metrics
  options += " --constantLabels='#{new_resource.constant_labels}'" if new_resource.constant_labels
  options += ' --auto-discover-databases' if new_resource.auto_discover_databases

  service_name = "prometheus-postgres-exporter-#{new_resource.instance_name}"

  # Create exporter user
  directory '/var/lib/prometheus'
  user 'postgres_exporter' do
    home        '/var/lib/prometheus/postgres_exporter'
    shell       '/usr/sbin/nologin'
    manage_home true
  end

  # Create exporters parent dir
  directory '/opt/prometheus'

  env = {}

  if new_resource.data_source_pass
    password = new_resource.data_source_pass
    password = password.call if password.is_a?(Proc)
    env['DATA_SOURCE_PASS'] = password
  end

  env['DATA_SOURCE_NAME'] = new_resource.data_source_name if new_resource.data_source_name
  env['DATA_SOURCE_URI'] = new_resource.data_source_uri if new_resource.data_source_uri
  env['DATA_SOURCE_USER'] = new_resource.data_source_user if new_resource.data_source_user
  env['DATA_SOURCE_USER_FILE'] = new_resource.data_source_user_file if new_resource.data_source_user_file
  env['DATA_SOURCE_PASS_FILE'] = new_resource.data_source_pass_file if new_resource.data_source_pass_file

  # Download binary
  remote_file 'postgres_exporter' do
    path "#{Chef::Config[:file_cache_path]}/postgres_exporter.tar.gz"
    owner 'root'
    group 'root'
    mode '0644'
    source node['prometheus_exporters']['postgres']['url']
    checksum node['prometheus_exporters']['postgres']['checksum']
  end

  bash 'untar_postgres_exporter' do
    code "tar -xzf #{Chef::Config[:file_cache_path]}/postgres_exporter.tar.gz -C /opt/prometheus"
    action :nothing
    subscribes :run, 'remote_file[postgres_exporter]', :immediately
  end

  bash 'move_postgres_exporter' do
    code "mv /opt/prometheus/postgres_exporter-#{node['prometheus_exporters']['postgres']['version']}.linux-amd64 /opt/prometheus/postgres_exporter-v#{node['prometheus_exporters']['postgres']['version']}"
    action :nothing
    subscribes :run, 'bash[untar_postgres_exporter]', :immediately
    only_if { Dir.exist?("/opt/prometheus/postgres_exporter-#{node['prometheus_exporters']['postgres']['version']}.linux-amd64") && !Dir.exist?("/opt/prometheus/postgres_exporter-v#{node['prometheus_exporters']['postgres']['version']}") }
  end

  link '/usr/local/bin/postgres_exporter' do
    to "/opt/prometheus/postgres_exporter-v#{node['prometheus_exporters']['postgres']['version']}/postgres_exporter"
  end

  service service_name do
    action :nothing
  end

  systemd_unit "#{service_name}.service" do
    content(
      'Unit' => {
        'Description' => 'Systemd unit for Prometheus PostgreSQL Exporter',
        'After'       => 'network-online.target',
      },
      'Service' => {
        'Type'             => 'simple',
        'User'             => new_resource.user,
        'Group'            => new_resource.user,
        'ExecStart'        => "/usr/local/bin/postgres_exporter #{options}",
        'Environment'      => env.map { |k, v| "'#{k}=#{v}'" }.join(' '),
        'WorkingDirectory' => '/var/lib/prometheus/postgres_exporter',
        'Restart'          => 'on-failure',
        'RestartSec'       => '30s',
        'PIDFile'          => '/run/postgres_exporter.pid',
      },
      'Install' => {
        'WantedBy' => 'multi-user.target',
      },
    )
    notifies :restart, "service[#{service_name}]"
    action :create
  end
end

action :enable do
  action_install
  service "prometheus-postgres-exporter-#{new_resource.instance_name}" do
    action :enable
  end
end

action :start do
  service "prometheus-postgres-exporter-#{new_resource.instance_name}" do
    action :start
  end
end

action :disable do
  service "prometheus-postgres-exporter-#{new_resource.instance_name}" do
    action :disable
  end
end

action :stop do
  service "prometheus-postgres-exporter-#{new_resource.instance_name}" do
    action :stop
  end
end
