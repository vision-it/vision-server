# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'vision_server' do
  context 'with defaults' do
    it 'run idempotently' do
      setup = <<-FILE
        file {'/etc/dhcp/dhclient-enter-hooks.d/':
          ensure => directory,
        }

        package { 'mariadb-server':
          ensure => present,
        }->
          exec { '/bin/cp -p /etc/init.d/mysql /etc/init.d/mariadb':
        }->
          exec { '/bin/bash /etc/init.d/mysql start':
        }
      FILE
      apply_manifest(setup, accept_all_exit_codes: true, catch_failures: false)

      pp = <<-FILE
        class { 'vision_server': }
      FILE

      apply_manifest(pp, catch_failures: false)
    end
  end

  context 'Exim provisioned' do
    describe package('exim4') do
      it { is_expected.to be_installed }
    end
    describe file('/etc/exim4/update-exim4.conf.conf') do
      it { is_expected.to be_file }
      its(:content) { is_expected.to match 'Puppet' }
      its(:content) { is_expected.to match 'localhost' }
    end
    describe file('/etc/mailname') do
      it { is_expected.to be_file }
    end
  end

  context 'SQL provisioned' do
    describe file('/root/.my.cnf') do
      it { is_expected.to be_file }
      it { is_expected.to be_mode 600 }
    end
    describe file('/root/init-db.sh') do
      it { is_expected.to be_file }
      it { is_expected.to be_mode 740 }
    end
    describe file('/etc/mysql/my.cnf') do
      it { is_expected.to be_file }
      its(:content) { is_expected.to match 'MANAGED BY PUPPET' }
      its(:content) { is_expected.to match 'bind-address = 127.0.0.1' }
    end
  end

  context 'Consul provisioned' do
    describe package('consul') do
      it { is_expected.to be_installed }
    end
    describe package('dnsmasq') do
      it { is_expected.to be_installed }
    end
    describe file('/etc/consul.d/consul.hcl') do
      it { is_expected.to exist }
      its(:content) { is_expected.to match 'Puppet' }
      its(:content) { is_expected.to match 'server = true' }
    end
    describe file('/etc/dnsmasq.conf') do
      it { is_expected.to exist }
      its(:content) { is_expected.to match '127.0.0.1' }
    end
    describe file('/etc/dnsmasq.d/10-consul') do
      it { is_expected.to exist }
      its(:content) { is_expected.to match '127.0.0.1' }
    end
    describe file('/etc/dhcp/dhclient-enter-hooks.d/keep-resolv') do
      it { is_expected.to exist }
      it { should be_mode 755 }
      its(:content) { is_expected.to match 'Puppet' }
      its(:content) { is_expected.to match 'make_resolv_conf' }
    end
    describe file('/etc/consul.d/service_example.json') do
      it { is_expected.to exist }
      its(:content) { is_expected.to match 'foobar' }
      its(:content) { is_expected.to match '1234' }
    end
  end
  context 'Nomad provisioned' do
    describe package('nomad') do
      it { is_expected.to be_installed }
    end
    describe file('/etc/nomad.d/anonymous.policy') do
      it { is_expected.to exist }
      its(:content) { is_expected.to match 'Puppet' }
      its(:content) { is_expected.to match 'deny' }
    end
    describe file('/etc/nomad.d/default.policy') do
      it { is_expected.to exist }
      its(:content) { is_expected.to match 'Puppet' }
      its(:content) { is_expected.to match 'read-job' }
    end
    describe file('/etc/systemd/system/nomad.service') do
      it { is_expected.to exist }
      its(:content) { is_expected.to match 'Puppet' }
      its(:content) { is_expected.to match 'consul' }
    end
  end
end
