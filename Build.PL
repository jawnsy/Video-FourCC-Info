#!/usr/bin/perl

# Build.PL
#  Script to build and install this distribution
#
# $Id: Build.PL 13 2009-01-15 18:19:07Z frequency $
#
# This helper script is hereby released into the public domain.

use strict;
use warnings;

use Module::Build;

my $builder = Module::Build->new(
  module_name           => 'Video::FourCC::Info',
  license               => 'perl',
  dist_author           => 'Jonathan Yu <frequency@cpan.org>',
  dist_version_from     => 'lib/Video/FourCC/Info.pm',
  dynamic_config        => 0,
  create_readme         => 1,
  recursive_test_files  => 1,
  sign                  => 1,
  create_packlist       => 1,

  # Maintain compatibility with ExtUtils::MakeMaker installations
  create_makefile_pl    => 'traditional',

  requires => {
    'perl'                    => '5.006',

    # Pragmatic and special modules
    'Carp'                    => '1.04',
    'version'                 => 0,
    'warnings'                => 0,
    'strict'                  => 0,

    # File manipulation modules
    'File::Spec'              => 0,
    'File::Basename'          => 0,

    # Database related modules
    'DBI'                     => 0,
    'DBD::SQLite'             => '1.14',
  },
  build_requires => {
    # User tests for good functionality
    'Test::More'              => '0.62',
    'Test::NoWarnings'        => '0.084',
  },
  recommends => {
    # Video::Info for detecting FourCC used in files
    # CPAN.pm cannot install Video::Info for some reason (due to a quirky
    # distribution?), so we have to install Video::Info::Magic
    'Video::Info::Magic'      => '1.01',

    # Optional module DateTime
    'DateTime'                => '0.4501',

    # Author tests
    'Test::Perl::Critic'      => 0,
    'Test::YAML::Meta'        => 0,
    'Test::Kwalitee'          => '1.01',
    'Test::Signature'         => 0,
    'Test::Pod'               => '1.14',
    'Test::Pod::Coverage'     => '1.04',
    'Test::DistManifest'      => 0,
  },
  conflicts => {
  },

  add_to_cleanup => [ 'Video-FourCC-Info-*' ],
  script_files => [
    'bin/peekvideo',
  ],

  meta_merge => {
    resources => {
      # Custom resources (must begin with an uppercase letter)
      Ratings      => 'http://cpanratings.perl.org/d/Video-FourCC-Info',

      # Official keys (homepage, license, bugtracker)
      repository   => 'http://svn.ali.as/cpan/trunk/Video-FourCC-Info',
      bugtracker   => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=Video-FourCC-Info',
      license      => 'http://dev.perl.org/licenses/',
    },
  },
);

$builder->add_build_element('dat');
$builder->create_build_script();