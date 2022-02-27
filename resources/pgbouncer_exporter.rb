resource_name :pgbouncer_exporter
provides :pgbouncer_exporter

property :instance_name,          String, name_property: true
property :user,                   String, default: 'pgbouncer_exporter'
property :log_level,              String, default: 'warn'
property :web_listen_address,     String, default: '0.0.0.0:9127'
property :connection_string,      String, default: 'postgresql://postgres:@127.0.0.1:6432/pgbouncer?sslmode=disable'
property :web_telemetry_path,     String

action :install do
  # Set property that can be queried with Chef search
  node.default['prometheus_exporters']['pgbouncer']['enabled'] = true

  options = "--web.listen-address '#{new_resource.web_listen_address}'"
  options += " --web.telemetry-path '#{new_resource.web_telemetry_path}'" if new_resource.web_telemetry_path
  options += " --pgBouncer.connectionString '#{new_resource.connection_string}'"
  options += " --log.level '#{new_resource.log_level}'"
  service_name = "prometheus-pgbouncer-exporter-#{new_resource.instance_name}"

  # Create exporter user
  directory '/var/lib/prometheus'
  user 'pgbouncer_exporter' do
    home        '/var/lib/prometheus/pgbouncer_exporter'
    shell       '/usr/sbin/nologin'
    manage_home true
  end

  # Create exporters parent dir
  directory '/opt/prometheus'

  # Download binary
  remote_file 'pgbouncer_exporter' do
    path "#{Chef::Config[:file_cache_path]}/pgbouncer_exporter.tar.gz"
    owner 'root'
    group 'root'
    mode '0644'
    source node['prometheus_exporters']['pgbouncer']['url']
    checksum node['prometheus_exporters']['pgbouncer']['checksum']
  end

  bash 'untar_pgbouncer_exporter' do
    code "tar -xzf #{Chef::Config[:file_cache_path]}/pgbouncer_exporter.tar.gz -C /opt/prometheus"
    action :nothing
    subscribes :run, 'remote_file[pgbouncer_exporter]', :immediately
  end

  bash 'move_pgbouncer_exporter' do
    code "mv /opt/prometheus/pgbouncer_exporter-#{node['prometheus_exporters']['pgbouncer']['version']}.linux-amd64 /opt/prometheus/pgbouncer_exporter-v#{node['prometheus_exporters']['pgbouncer']['version']}"
    action :nothing
    subscribes :run, 'bash[untar_pgbouncer_exporter]', :immediately
    only_if { Dir.exist?("/opt/prometheus/pgbouncer_exporter-#{node['prometheus_exporters']['pgbouncer']['version']}.linux-amd64") && !Dir.exist?("/opt/prometheus/pgbouncer_exporter-v#{node['prometheus_exporters']['pgbouncer']['version']}") }
  end

  link '/usr/local/bin/pgbouncer_exporter' do
    to "/opt/prometheus/pgbouncer_exporter-v#{node['prometheus_exporters']['pgbouncer']['version']}/pgbouncer_exporter"
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
        'ExecStart'        => "/usr/local/bin/pgbouncer_exporter #{options}",
        'WorkingDirectory' => '/var/lib/prometheus/pgbouncer_exporter',
        'Restart'          => 'on-failure',
        'RestartSec'       => '30s',
        'PIDFile'          => '/run/pgbouncer_exporter.pid',
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
  service "prometheus-pgbouncer-exporter-#{new_resource.instance_name}" do
    action :enable
  end
end

action :start do
  service "prometheus-pgbouncer-exporter-#{new_resource.instance_name}" do
    action :start
  end
end

action :disable do
  service "prometheus-pgbouncer-exporter-#{new_resource.instance_name}" do
    action :disable
  end
end

action :stop do
  service "prometheus-pgbouncer-exporter-#{new_resource.instance_name}" do
    action :stop
  end
end
