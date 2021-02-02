# encoding: utf-8

title 'Test PGBouncer installation'

DISTROS = {
  '9'  => 'stretch',
  '10' => 'buster',
}

distro = DISTROS[os[:release].to_s.split('.').first]

# Test PGBouncer package
describe package('pgbouncer') do
  it { should be_installed }

  case distro
  when 'stretch'
    its('version') { should eq '1.15.0-1.pgdg90+1' }
  when 'buster'
    its('version') { should eq '1.15.0-1.pgdg100+1' }
  end
end

# Test PGBouncer service
describe service('pgbouncer') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe port(6432) do
  its('processes') { should include 'pgbouncer' }
  its('protocols') { should include 'tcp' }
  its('addresses') { should include '127.0.0.1' }
end
