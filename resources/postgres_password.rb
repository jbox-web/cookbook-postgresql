resource_name :postgres_password
provides :postgres_password

property :user,       String, name_property: true
property :pass,       [String, Proc], name_property: true
property :admin_user, String, default: 'postgres'

action :install do
  password = new_resource.pass
  password = password.call if password.is_a?(Proc)
  execute "psql -U #{new_resource.admin_user} -c \"ALTER user #{new_resource.user} with password '#{password}';\""
end
