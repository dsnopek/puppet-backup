
class backup ($duplicity_passphrase = 'backmeup', $aws_access_key_id = '', $aws_secret_access_key = '', $fulldays = '30D', $maxfull = '3', $extra_duplicity_options = '') {

  include apt::backports
  file {'/etc/apt/preferences.d/duplicity.pref':
    ensure => present,
    source => "puppet:///modules/backup/duplicity.pref",
    notify => Exec['update_apt'];
  }

  # For S3 support
  package {'python-boto':
  	ensure  => present,
  }

  package {'duplicity':
    ensure  => present,
    require => [
      File['/etc/apt/preferences.d/duplicity.pref'],
      Class["apt::backports"],
      Exec['update_apt'],
      Package['python-boto'],
    ],
  }

  file {'/etc/duplicity':
    ensure => directory,
    owner  => '0',
    group  => '0',
    mode   => '0700',
  }

  file {'/etc/duplicity/defaults.conf':
  	ensure  => file,
	owner   => '0',
	group   => '0',
	mode    => '0700',
	content => template('backup/defaults.conf'),
	require => File['/etc/duplicity'],
  }
}

