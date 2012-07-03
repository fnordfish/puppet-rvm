define rvm::define::wrapper(
  $ensure = 'present',
  $ruby_version,
  $prefix,
  $gemset = '',
) {
  Exec {
    path    => '/usr/local/rvm/bin:/bin:/sbin:/usr/bin:/usr/sbin',
  }
  $rvm_source = "source /usr/local/rvm/scripts/rvm"
  $wrapper_exists = "bash -c '${rvm_source} ; rvm use ${ruby_version} ; which ${prefix}_${name}'"

  if $gemset == '' {
    $rvm_depency = "install-ruby-${ruby_version}"
    $rubyset_version = $ruby_version
  } else {
    $rvm_depency = "rvm-gemset-create-${gemset}-${ruby_version}"
    $rubyset_version = "${ruby_version}@${gemset}"
  }

  if $ensure == 'present' {
    exec { "rvm-alias-create-${name}-${rubyset_version}":
      command => "bash -c '${rvm_source} ; rvm use ${rubyset_version} ; rvm wrapper ${rubyset_version} ${prefix} ${name}'",
      unless => $wrapper_exists,
      require => [Class['rvm'], Exec[$rvm_depency]],
    }
  } elsif $ensure == 'absent' {
    exec { "rvm-gemset-delete-${name}-${rubyset_version}":
      command => "bash -c '${rvm_source} ; rvm use ${rubyset_version} ; rm `which ${prefix}_${name}`'",
      onlyif => $wrapper_exists,
      require => [Class['rvm'], Exec[$rvm_depency]],
    }
  }
}
