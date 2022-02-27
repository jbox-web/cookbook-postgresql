if node['prometheus_exporters']['pgbouncer']['install']
  pgbouncer_exporter 'main' do
    action %i(install enable start)
  end
end
