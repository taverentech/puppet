# == Class: base::ldapclient  debian
#
# === Parameters
#
# [*basedn*]
# Specifies the default base DN to use when performing ldap
# operations. The base must be specified as a Distinguished
# Name in LDAP format.
#
# [*ldapuri*]
# The URI of an LDAP server to which the LDAP library should
# connect.
#
# [*tls_enabled*]
# Enable Transport Layer Security support.
#
# [*tls_cert_path*]
# Specifies the file that contains certificates for all of the
# Certificate Authorities the client will recognize.
# Ignored unless tls_enabled == true.
#
# [*tls_cacert*]
# The source file that should be served from Puppet. This file
# must exist under the '${module_path}/modulename/files/' directory.
# Ignored unless tls_enabled == true.
#
# [*tls_reqcert*]
# Specifies what checks to perform on server certificates in a
# TLS session, if any. See man ldap.conf 5.
# Ignored unless tls_enabled == true.
#
# [*timelimit*]
# Specifies a time limit (in seconds) to use when performing
# searches. The number should be a non-negative integer.
#
# [*network_timeout*]
# Specifies the network timeout (in seconds) in case of no activity.
#
# === Variables
#
# === Examples
#
# class { 'openldap::client::debian':
# basedn => 'dc=puppetlabs,dc=com',
# ldapuri => 'ldap://ldap.puppetlabs.com',
# tls_enabled => true,
# }
#
# === Authors
#
# Kelsey Hightower kelsey@puppetlabs.com
#
# === Copyright
#
# Copyright 2012 Puppet Labs, Inc
#
class base::ldap (
  $basedn = 'dc=example1,dc=com',
  #$ldapuri,
  $tls_enabled = false,
  $tls_cacert_path = "/etc/ssl/certs/openldap_cacert.pem",
  $tls_cacert = "openldap_cacert.pem",
  $tls_reqcert = "demand",
  $timelimit = 15,
  $network_timeout = 30,
) {

  ###############################################################
  ## VARs
  # Set ldap URI by pop - used by ldap.conf templates
  # ldapuri => 'ldap://ldap.puppetlabs.com',
  $ldapuri = $::pop ? {
    "iad1" => "ldap://ldap1.iad1.prod.example1.com",
    "sjc1" => "ldap://ldap1.sjc1.eng.example1.com",
    default=> "ldap://ldap1.sjc1.eng.example1.com",
  }
  notify{"DEBUG: ldapuri is $ldapuri": }

  $ldapclientpkgs = [
    'ldap-auth-client',
    'ldap-auth-config',
    'libnss-ldap',
    'libpam-ldap',
  ]
    #'ldap-utils', # already in base::packages

  package { $ldapclientpkgs:
    ensure => installed,
  }

  if $tls_enabled {
    file { "$tls_cacert_path":
      ensure => file,
      owner => 'root', group => 'root', mode => '0644',
      source => "puppet:///modules/base/ldap/$tls_cacert",
    }
  }

  # Client config, /etc/ldap/ldap.conf is server config
  file { '/etc/ldap.conf':
    ensure => file,
    owner => 'root', group => 'root', mode => '0644',
    backup => ".$::timestamp",
    content => template("base/ldap.conf.erb"),
    notify => Service[ ["nscd"],["idmapd"] ],
  }

  file { '/etc/nsswitch.conf':
    ensure => file,
    owner => 'root', group => 'root', mode => '0644',
    backup => ".$::timestamp",
    source => 'puppet:///modules/base/nsswitch.conf',
    notify => Service[ ["nscd"],["idmapd"] ],
  }

  #########################################################
  # Configure PAM to use LDAP
  #
  file { '/etc/pam.d/common-session':
    ensure => file,
    owner => 'root', group => 'root', mode => '0644',
    source => "puppet:///modules/base/pam.d/common-session",
    require => Package['libpam-ldap'],
    notify => Service[ ["nscd"],["idmapd"] ],
  }

  file { '/etc/pam.d/common-password':
    ensure => file,
    owner => 'root', group => 'root', mode => '0644',
    source => "puppet:///modules/base/pam.d/common-password",
    require => Package['libpam-ldap'],
    notify => Service[ ["nscd"],["idmapd"] ],
  }

  file { '/etc/pam.d/common-session-noninteractive':
    ensure => file,
    owner => 'root', group => 'root', mode => '0644',
    source => "puppet:///modules/base/pam.d/common-session-noninteractive",
    require => Package['libpam-ldap'],
    notify => Service[ ["nscd"],["idmapd"] ],
  }
  
  file { '/etc/pam.d/common-auth':
    ensure => file,
    owner => 'root', group => 'root', mode => '0644',
    source => "puppet:///modules/base/pam.d/common-auth",
    require => Package['libpam-ldap'],
    notify => Service[ ["nscd"],["idmapd"] ],
  }

  file { '/etc/pam.d/common-account':
    ensure => file,
    owner => 'root', group => 'root', mode => '0644',
    source => "puppet:///modules/base/pam.d/common-account",
    require => Package['libpam-ldap'],
    notify => Service[ ["nscd"],["idmapd"] ],
  }

}

