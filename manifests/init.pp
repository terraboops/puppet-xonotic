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

	package { 'upstart':
		ensure => 'installed'
	}

	staging::deploy { 'xonotic-0.8.1.zip':
		source => 'http://dl.xonotic.org/xonotic-0.8.1.zip',
		target => '/srv/',
		require => [File['/srv/'], Package['unzip']],
		timeout => 0
	}

	if $xonotic_mappack_url {
		file { 'xonotic-maps':
			path => '/srv/xonotic-maps',
			ensure => 'directory',
		}

		staging::deploy { 'map-pack':
			source => $facts['xonotic-mappack-url'],
			target => getparam(File['xonotic-maps'], 'path'),
		}

		include ::apache
		class{ 'apache':
			docroot => getparam(File['xonotic-maps'], 'path'),
		}
	}

}
