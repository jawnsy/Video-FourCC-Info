#!/usr/bin/perl -T

# t/99data.t
#  Test data constraints of the SQLite database
#
# $Id$
#
# This test script is hereby released into the public domain.

use strict;
use warnings;

use Test::More;

use File::Spec;

unless ($ENV{TEST_AUTHOR} or $ENV{TEST_DATA}) {
  plan skip_all => 'Set TEST_AUTHOR or TEST_DATA to check data integrity';
}

use DBI ();

# Find the codec database, relative to the main dist dir
my $data = File::Spec->catfile(
  'lib',
  'Video',
  'FourCC',
  #'Info.pm', # same directory, different filename :-)
  'codecs.dat'
);

# Open the database
my $dbh = DBI->connect(
  'dbi:SQLite:dbname=' . $data,
  'notused', # cannot be null, or DBI complains
  'notused',
  {
    RaiseError => 1,
    AutoCommit => 1,
    PrintError => 0,
  }
);

my $rowcount;

# Get the number of rows in our database
{
  my $sth = $dbh->prepare('SELECT COUNT(*) FROM fourcc');
  $sth->execute();
  ($rowcount) = $sth->fetchrow_array();
}

# Set up one test per row
plan tests => $rowcount;

# Check database constraints.  This is a pretty heavy test, since it needs
# to probe each row, which is why this is set as an author test :-)
my $sth = $dbh->prepare('SELECT * FROM fourcc');
$sth->execute();

my $row = 1;

# Grab the first and only array element; this is the FourCC
while (defined (my $href = $sth->fetchrow_hashref())) {
  my $ok = 1;

  # Each FourCC must be:
  # - Defined
  # - Four characters long (space-padded if necessary)
  # - Uppercased
  if (!exists $href->{fourcc}) {
    diag('Found NULL FourCC in database');
    $ok = 0;
    next;
  }

  my $code = $href->{fourcc};
  if (length $code != 4) {
    diag('FourCC "', $code, '" is ', length $code, ' bytes! (should be 4)');
    $ok = 0;
  }

  if ($code ne uc($code)) {
    diag('FourCC "', $code, '" is not uppercase');
    $ok = 0;
  }

  # Each owner name must be:
  # - Without leading or trailing spaces
  if (defined $href->{owner}) {
    if ($href->{owner} =~ /^\s+/s) {
      diag('Owner data of FourCC "', $code, '" has leading spaces');
      $ok = 0;
    }
    if ($href->{owner} =~ /\s+$/s) {
      diag('Owner data of FourCC "', $code, '" has trailing spaces');
      $ok = 0;
    }
  }

  # Each date must be:
  # - In yyyy-mm-dd format
  if (defined $href->{registered}) {
    if ($href->{registered} !~ /^\d{4}-\d{2}-\d{2}/s) {
      diag('Registration date of FourCC "', $code, '" is invalid');
      $ok = 0;
    }
  }

  # Each description must be:
  # - Defined (not NULL)
  # - Without leading or trailing spaces
  if (defined $href->{description}) {
    if ($href->{description} =~ /^\s+/s) {
      diag('Description of FourCC "', $code, '" has leading spaces');
      $ok = 0;
    }
    if ($href->{description} =~ /\s+$/s) {
      diag('Description of FourCC "', $code, '" has trailing spaces');
      $ok = 0;
    }
  }
  else {
    diag('Description of FourCC "', $code, '" is NULL!');
    $ok = 0;
  }

  ok($ok, 'Database values appear sane for row ' . $row);
  $row++;
}
