class netdata::install inherits netdata {

  case $::operatingsystem {
    /(?i:debian|ubuntu)/: {
      ensure_packages(
        ['zlib1g-dev', 'uuid-dev', 'libmnl-dev', 'gcc',
          'autoconf', 'autoconf-archive', 'autogen', 'automake', 'pkg-config',
          'curl'],
        {'ensure' => 'present'})
    }
    /(?i:redhat|centos)/: {
      ensure_packages(
        [ 'autoconf', 'automake', 'curl', 'gcc', 'libmnl-devel', 'libuuid-devel', 'lm_sensors',
          'MySQL-python', 'nc', 'pkgconfig', 'python', 'python-psycopg2',
          'PyYAML', 'zlib-devel'],
        {'ensure' => 'present'})
    }
    default: {
      fail("Module ${module_name} has no config for ${::operatingsystem}")
    }
  }

  # git is already defined in puppet module
  # make is already in make module

  # download it - the directory 'netdata' will be created
  git::repo{ 'netdata':
    path   => '/usr/local/src/netdata',
    source => 'https://github.com/firehol/netdata.git'
  }

  # build it, install it, start it
  # cd netdata
  # ./netdata-installer.sh
  exec { 'Install_netdata':
    command => "/opt/netdata/netdata-installer.sh --install ${install_dir}",
    cwd     => '/opt/netdata',
    creates => '/etc/netdata',
  }

  # Memory de-duplication instructions - If you enable it, you will save 40-60% of netdata memory.
  # echo 1 >/sys/kernel/mm/ksm/run
  # echo 1000 >/sys/kernel/mm/ksm/sleep_millisecs
  if($netdata::name) {
    sysctl::value {
      "kernel.mm.ksm.run": value => "1"
    }
    sysctl::value {
      "kernel.mm.ksm.sleep_millisecs": value => "1000"
    }
  }
}
