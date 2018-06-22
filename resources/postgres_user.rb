resource_name :postgres_user
provides :postgres_user

property :user,       String, name_property: true
property :admin_user, String, default: 'postgres'

action :install do
  execute "createuser -U #{new_resource.admin_user} -SDRw #{new_resource.user}" do
    only_if { !ChefPostgresqlCookbook::Helper.user_exists?(new_resource.user) }
  end
end
