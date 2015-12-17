# == Class: xonotic
#
# Installs Xonotic
#
# === Authors
#
# Tyler Mauthe <me@tylermauthe.com>
#
# === Copyright
#
# Copyright 2015 Tyler Mauthe, but whatever.
#
class xonotic {

	include ::stdlib
	include ::staging

	file { '/srv/':
		ensure => 'directory',
	}

	package { 'unzip':
		ensure => 'installed'
	}

	staging::deploy { 'xonotic-0.8.1.zip':
		source => 'http://dl.xonotic.org/xonotic-0.8.1.zip',
		target => '/srv/',
		require => [File['/srv/'], Package['unzip']],
		timeout => 0
	}

	file { '/lib/systemd/system/xonotic.service':
		source => 'puppet:///modules/xonotic/init/systemd/xonotic.service',
		require => Staging::Deploy['xonotic-0.8.1.zip']
	}

	file { '/srv/Xonotic/data/server.cfg':
		source => 'puppet:///modules/xonotic/xonotic/server.cfg',
		require => Staging::Deploy['xonotic-0.8.1.zip']
	}

	service { 'xonotic':
		ensure => 'running',
		enable => true,
		require => File['/lib/systemd/system/xonotic.service']
	}

	if $xonotic_map_url {
		class { 'apache':
			docroot => '/srv/Xonotic/data',
			ensure => 'installed'
		}

		staging::deploy { 'map-pack.tar':
			source => $xonotic_map_url,
			target => '/srv/Xonotic/data',
			require => Staging::Deploy['xonotic-0.8.1.zip'],
			timeout => 0
		}

	}

}
