
class backup::mysql ($s3path = 'UNSET', $mysql_user = 'backupdb', $mysql_password, $hour = 2, $minute = 0) {
  validate_re($s3path, '^s3\+http://[0-9a-zA-Z\./]+$')
  validate_string($mysql_user)
  validate_string($mysql_password)

  database_user {"$mysql_user@localhost":
  	ensure        => present,
	password_hash => mysql_password($mysql_password),
  }

  database_grant {"$mysql_user@localhost":
  	privileges => ['Select_priv', 'Reload_priv', 'Show_db_priv', 'Lock_tables_priv'],
  }

  file {'/usr/local/sbin/duplicity-backup-db.sh':
    ensure  => file,
    owner   => '0',
    group   => '0',
    mode    => '0700',
    content => template('backup/duplicity-backup-db.sh'),
    require => [ Class['backup'], Database_grant["$mysql_user@localhost"] ]
  }

  cron {'duplicity-backup-db.sh':
    command => "/usr/local/sbin/duplicity-backup-db.sh",
    user    => root,
    hour    => $hour,
    minute  => $minute,
    require => File['/usr/local/sbin/duplicity-backup-db.sh'],
  }
}

