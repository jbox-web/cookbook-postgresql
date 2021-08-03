resource_name :postgres_user
provides :postgres_user
unified_mode true

property :user,       String, name_property: true
property :rights,     String, default: '-SDRw'
property :admin_user, String, default: 'postgres'

action :install do
  execute "createuser -U #{new_resource.admin_user} #{new_resource.rights} #{new_resource.user}" do
    only_if { !ChefPostgresqlCookbook::Helper.user_exists?(new_resource.user) }
  end
end
