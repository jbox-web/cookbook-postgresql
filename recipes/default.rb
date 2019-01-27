version = node[:postgres][:version]

# Install GPG
package 'dirmngr'

# Install Postgresql repository
apt_repository 'stretch-postgresql-binary' do
  uri          'http://apt.postgresql.org/pub/repos/apt'
  key          'https://www.postgresql.org/media/keys/ACCC4CF8.asc'
  components   [(version.to_s == '10' ? 'main' : version)]
  distribution 'stretch-pgdg'
end
