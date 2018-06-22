# encoding: utf-8

title 'Test PGBouncer installation'

# Test PGBouncer package
describe package('pgbouncer') do
  it { should be_installed }
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
