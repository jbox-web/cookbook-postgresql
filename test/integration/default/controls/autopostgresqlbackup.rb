# encoding: utf-8

title 'Test AutoPostgreSQLBackup installation'

describe package('autopostgresqlbackup') do
  it { should be_installed }
end

describe file('/usr/sbin/autopostgresqlbackup') do
  it { should exist }
  its('owner') { should eq 'root' }
  its('group') { should eq 'root' }
  its('mode')  { should cmp '0755' }
end

describe file('/etc/cron.daily/autopostgresqlbackup') do
  it { should exist }
  its('owner') { should eq 'root' }
  its('group') { should eq 'root' }
  its('mode')  { should cmp '0755' }
end

describe file('/etc/default/autopostgresqlbackup') do
  it { should exist }
  its('owner') { should eq 'root' }
  its('group') { should eq 'root' }
  its('mode')  { should cmp '0644' }
  its('content') { should include 'BACKUPDIR="/var/backups/postgresql"'  }
  its('content') { should include 'MAILCONTENT="quiet"'  }
end

describe directory('/var/backups/postgresql') do
  it { should exist }
  its('owner') { should eq 'root' }
  its('group') { should eq 'root' }
  its('mode')  { should cmp '0700' }
end
