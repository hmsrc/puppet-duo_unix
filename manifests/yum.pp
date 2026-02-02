# == Class: duo_unix::yum
#
# Provides duo_unix for a yum-based environment (e.g. RHEL/CentOS)
#
# === Authors
#
# Mark Stanislav <mstanislav@duosecurity.com>
#
class duo_unix::yum {
  $repo_uri = 'http://yumrepos.med.harvard.edu'
  $package_state = $::duo_unix::package_version

  # Map Amazon Linux to RedHat equivalent releases
  # Map RedHat 5 to CentOS 5 equivalent releases
  if $::operatingsystem == 'Amazon' {
    $releasever = $::operatingsystemmajrelease ? {
      '2014'  => '6Server',
      default => undef,
    }
    $os = $::operatingsystem
  } elsif ( $::osfamily == 'RedHat' ) {
    if $facts['os']['name'] == 'CentOS' {
      $os = 'centos'
    } elsif $facts['os']['name'] == 'AlmaLinux' {
      $os = 'rocky'
    } elsif $facts['os']['name'] == 'Rocky' {
      $os = 'rocky'
    } else {
      $os = 'centos'
    }
  } else {
    $os = $::operatingsystem
  }

  if $releasever == undef {
    $releasever = '$releasever'
  }

  yumrepo { 'duosecurity':
    descr    => 'Duo Security Repository',
    baseurl  => "${repo_uri}/${os}-${releasever}/duosecurity",
    gpgcheck => '0',
    enabled  => '1',
    priority => '1',
  }

  if $duo_unix::manage_ssh {
    package { 'openssh-server':
      ensure => installed;
    }
  }

  package { $duo_unix::duo_package:
    ensure  => $package_state,
    require => Yumrepo['duosecurity'];
  }
}
