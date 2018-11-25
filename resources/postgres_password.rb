resource_name :postgres_password
provides :postgres_password

property :db_name,    String, name_property: true
property :user,       String, name_property: true
property :pass,       [String, Proc], name_property: true
property :admin_user, String,  default: 'postgres'
property :host,       String,  default: 'localhost'
property :port,       Integer, default: 5432

action :install do
  password = new_resource.pass
  password = password.call if password.is_a?(Proc)
  execute "psql -U #{new_resource.admin_user} -c \"ALTER user #{new_resource.user} with password '#{password}';\"" do
    only_if { ChefPostgresqlCookbook::Helper.connection_failed?(new_resource.host, new_resource.port, new_resource.db_name, new_resource.user, password) }
  end
end
