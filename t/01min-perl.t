#!/usr/bin/perl

# t/01min-perl.t
#  Tests that the minimum required Perl version matches META.yml
#
# $Id$
#
# This test script is hereby released into the public domain.

use strict;
use warnings;

use Test::More;

unless ($ENV{TEST_AUTHOR}) {
  plan(skip_all => 'Set TEST_AUTHOR to enable module author tests');
}

eval {
  require Test::MinimumVersion;
};
if ($@) {
  plan skip_all => 'Test::MinimumVersion required to test minimum Perl';
}

Test::MinimumVersion->import();

all_minimum_version_from_metayml_ok();
