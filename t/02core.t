#!/usr/bin/perl -T

# t/02core.t
#  Tests core functionality
#
# $Id: 02manifest.t 5 2008-12-25 23:16:47Z frequency $
#
# This test script is hereby released into the public domain.

use strict;
use warnings;

use Test::More tests => 7;
use Test::NoWarnings;

use Video::FourCC::Info;

# Normal operation
{
  my $codec = Video::FourCC::Info->new('DIV3');
  isa_ok($codec, 'Video::FourCC::Info');

  is($codec->code, 'DIV3', 'FourCC code is DIV3');
  is($codec->description, 'DivX 3 Low-Motion', 'DivX 3 Low Motion Codec');
  is($codec->owner, 'DivX');
}

# Static usage of module
{
  my $fourcc = Video::FourCC::Info->describe('DIV3');
  is($fourcc, 'DivX 3 Low-Motion', 'Use of class method describe');
}

# Check that the date parsed is appropriate
{
  my $codec = Video::FourCC::Info->new('CC12');

  eval { require DateTime };

  # If there is no DateTime, then the registered date will be a simple
  # string; otherwise, we have to stringify DateTime
  is($@ ? $codec->registered : $codec->registered->ymd('-'), '1996-06-12',
    'Intel YUV12 codec register date');
}

# Test that nothing bad happens when there is missing info
# If nothing happens, then we're successful; otherwise it's likely there
# will be a warning, which is caught by Test::NoWarnings
{
  Video::FourCC::Info->new('ACTL'); # No date or owner known
}