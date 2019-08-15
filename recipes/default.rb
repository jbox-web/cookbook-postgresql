version = node[:postgres][:version]

DISTROS = {
  '9'  => 'stretch',
  '10' => 'buster',
}

# Install GPG
package 'dirmngr'

# Install Postgresql repository
apt_repository 'postgresql-binary' do
  distro = DISTROS[node[:platform_version]]

  uri          'http://apt.postgresql.org/pub/repos/apt'
  key          'https://www.postgresql.org/media/keys/ACCC4CF8.asc'
  components   [(version.to_s == '10' ? 'main' : version)]
  distribution "#{distro}-pgdg"
end
