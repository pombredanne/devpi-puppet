# == Class: devpi::nginx_config
#
# NginX configuration.
#
class devpi::nginx_config {
    $username       = $devpi::config::username
    $dataroot       = $devpi::config::dataroot

    if $devpi::nginx::ensure {
        package { 'nginx': ensure => $devpi::nginx::ensure, name => 'nginx-full' }
    }

    if $devpi::nginx::www_default_disable {
        file { '/etc/nginx/sites-enabled/default':
            ensure      => absent,
            require     => [Package['nginx'],],
        }
    }

    file { '/etc/nginx/sites-available/devpi':
        ensure      => present,
        content     => template('devpi/nginx-devpi.conf'),
        owner       => 'root',
        group       => 'root',
        require     => [Package['nginx'],],
    }
    ->
    file { '/etc/nginx/sites-enabled/devpi':
        ensure      => link,
        target      => '../sites-available/devpi',
    }

    file { "${dataroot}/www":
        ensure      => directory,
        mode        => 0755,
        require     => [User[$username],],
    }
    ->
    file { "${dataroot}/www/favicon.ico":
        ensure      => present,
        source      => 'puppet:///modules/devpi/favicon.ico',
    }
}