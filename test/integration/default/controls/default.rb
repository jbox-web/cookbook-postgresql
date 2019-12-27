# encoding: utf-8

title 'Test Postgresql installation'

DISTROS = {
  '9'  => 'stretch',
  '10' => 'buster',
}

# Test Postgresql packages
describe package('postgresql-10') do
  it { should be_installed }
end

describe package('libpq-dev') do
  it { should be_installed }
end

distro = DISTROS[os[:release].to_s.split('.').first]

describe file('/etc/apt/sources.list.d/postgresql-binary.list') do
  it { should exist }
  its('content') { should include %Q(deb      http://apt.postgresql.org/pub/repos/apt #{distro}-pgdg main)  }
end

# Test Postgresql config
describe file('/etc/postgresql/10/main/postgresql.conf') do
  it { should exist }
  its('owner') { should eq 'postgres' }
  its('group') { should eq 'postgres' }
  its('mode')  { should cmp '0644' }
end

describe directory('/data/postgresql/10/main') do
  it { should exist }
  its('owner') { should eq 'postgres' }
  its('group') { should eq 'postgres' }
  its('mode')  { should cmp '0700' }
end

# Test Postgresql service
describe service('postgresql') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe port(5432) do
  its('processes') { should include 'postgres' }
  its('protocols') { should include 'tcp' }
  its('addresses') { should include '127.0.0.1' }
end
