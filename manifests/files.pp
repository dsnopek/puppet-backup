
class backup::files ($filelist = "UNSET", $s3path = "UNSET", $hour = 2, $minute = 0) {
  validate_array($filelist)
  validate_re($s3path, '^s3\+http://[0-9a-zA-Z\./]+$')

  file {'/etc/duplicity/server-filelist.txt':
    ensure  => file,
    owner   => '0',
    group   => '0',
    mode    => '0644',
    content => template('backup/server-filelist.txt'),
    require => File['/etc/duplicity'],
  }

  file {'/usr/local/sbin/duplicity-backup-files.sh':
    ensure  => file,
    owner   => '0',
    group   => '0',
    mode    => '0700',
    content => template('backup/duplicity-backup-files.sh'),
    require => Class['backup'],
  }

  cron {'duplicity-backup-files.sh':
    command => "/usr/local/sbin/duplicity-backup-files.sh",
    user    => root,
    hour    => $hour,
    minute  => $minute,
    require => File['/usr/local/sbin/duplicity-backup-files.sh'],
  }
}

