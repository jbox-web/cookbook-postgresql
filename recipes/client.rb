# Include main recipe (install apt repo)
include_recipe 'postgresql'

# Get current version
version = node[:postgres][:version]

# Install packages
package [
  "postgresql-client-#{version}",
  'libpq-dev',
]
