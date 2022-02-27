if node['prometheus_exporters']['postgres']['install']
  postgres_exporter 'main' do
    action %i(install enable start)
  end
end
