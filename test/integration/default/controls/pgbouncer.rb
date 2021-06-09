# encoding: utf-8

title 'Test PGBouncer installation'

# Fetch Inspec inputs
debian_release    = input('debian_release')
pgbouncer_version = input('pgbouncer_version')

# Test PGBouncer package
describe package('pgbouncer') do
  it { should be_installed }
  its('version') { should eq pgbouncer_version }
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
