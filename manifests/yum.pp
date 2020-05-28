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
  } elsif ( $::operatingsystem == 'RedHat' and
            $::operatingsystemmajrelease == 5 ) {
    $os = 'CentOS'
    $releasever = '$releasever'
  } elsif ( $::operatingsystem == 'OracleLinux' ) {
    $os = 'CentOS'
    $releasever = '$releasever'
  } else {
    $os = $::operatingsystem
    $releasever = '$releasever'
  }

  yumrepo { 'duosecurity':
    descr    => 'Duo Security Repository',
    baseurl  => "${repo_uri}/centos-${releasever}/duosecurity",
    gpgcheck => '0',
    enabled  => '1',
  }

  if $duo_unix::manage_ssh {
    package { 'openssh-server':
      ensure => installed;
    }
  }

  package {  $duo_unix::duo_package:
    ensure  => $package_state,
    require => Yumrepo['duosecurity'] ;
  }

}
