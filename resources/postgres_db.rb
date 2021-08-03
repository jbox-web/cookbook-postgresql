resource_name :postgres_db
provides :postgres_db
unified_mode true

property :name,       String, name_property: true
property :user,       String, name_property: true
property :admin_user, String, default: 'postgres'
property :encoding,   String, default: 'UTF8'
property :template,   String, default: 'template0'

action :install do
  execute "createdb -U #{new_resource.admin_user} -O #{new_resource.user} -E #{new_resource.encoding} -T #{new_resource.template} #{new_resource.name}" do
    only_if { !ChefPostgresqlCookbook::Helper.db_exists?(new_resource.name) }
  end
end
