# Include main recipe (install apt repo)
include_recipe 'postgresql'

# Get current version
version = node[:postgres][:version]

# Install Postgresql client
package "postgresql-client-#{version}"

# Install Postgresql dev package
package 'libpq-dev'
