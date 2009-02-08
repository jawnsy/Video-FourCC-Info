# Video::FourCC::Info
#  Shows information about codecs specified as a Four Character Code
#
# $Id$
#
# Copyright (C) 2009 by Jonathan Yu <frequency@cpan.org>
#
# This package is distributed with the same licensing terms as Perl itself.
# For additional information, please read the included `LICENSE' file.

package Video::FourCC::Info;

use strict;
use warnings;

use Carp ();

use DBI ();

use File::Basename ();
use File::Spec     ();

# Use DateTime if available
eval { require DateTime; };

# Look for the data file in the same folder as this module
my $data = File::Spec->catfile(
  File::Basename::dirname(__FILE__),
  'codecs.dat'
);

# Since this is a 
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

=head1 NAME

Video::FourCC::Info - Find information about codecs specified as Four
Character Code

=head1 VERSION

Version 1.1.1 ($Id$)

=cut

use version; our $VERSION = qv('1.1.1');

=head1 DESCRIPTION

In order for video players to detect the algorithm required to decode a given
video file, a four-byte sequence called a Four Character Code is written
somewhere in the header of the file. This ensures that the detected codec
format is independent of the file extension, which may be incorrect due to
human error or for some other reason.

This is similar to the four-byte "magic number" used by the UNIX file(1)
command to roughly determine a file format.

Most applications seem to treat this as a case insensitive code. As a result,
internally, your given FourCC's will be silently converted to uppercase.

=head1 SYNOPSIS

  use Video::FourCC::Info;

  my $codec = Video::FourCC::Info->new('DIV3');

  printf "Codec description: %s\n", $codec->description;

=head1 COMPATIBILITY

This module was tested under Perl 5.10.0, using Debian Linux. However, because
it's Pure Perl and doesn't do anything too obscure, it should be compatible
with any version of Perl that supports its prerequisite modules.

If you encounter any problems on a different version or architecture, please
contact the maintainer.

=head1 METHODS

=head2 Video::FourCC::Info->new( $fourcc )

Creates a C<Video::FourCC::Info> object, which provides information about
the given Four Character Code. If the code does not exist in the database,
it will return an error.

Example code:

  my $codec = Video::FourCC::Info->new('DIV3');

This method will return an appropriate B<Video::FourCC::Info> object or throw
an exception on error.

=cut

sub new {
  my ($class, $fourcc) = @_;

  Carp::croak('You must call this as a class method') if ref($class);
  Carp::croak('You must specify a FourCC') unless defined($fourcc);

  $fourcc = uc($fourcc);

  my $self = {
    fourcc         => $fourcc,
  };

  my $sth = $dbh->prepare('SELECT * FROM fourcc WHERE fourcc = ?');
  $sth->execute($fourcc);

  my $href = $sth->fetchrow_hashref;
  if (defined $href) {
    if (defined $href->{description}) {
      $self->{desc}  = $href->{description};
    }
    if (defined $href->{owner}) {
      $self->{owner} = $href->{owner};
    }
    if (defined $href->{registered}) {
      # If we have a DateTime object, we should parse the date and store it
      if (exists $INC{'DateTime.pm'}) {
        my ($year, $month, $day) = split(/-/, $href->{registered});
        $self->{regdate} = DateTime->new(
          year    => $year,
          month   => $month,
          day     => $day,
        );
      }
      # Otherwise, we have to store the date as a simple string
      else {
        $self->{regdate} = $href->{registered};
      }
    }
  }
  else {
    Carp::croak('FourCC ' . $fourcc . ' was not found in the database');
  }

  return bless($self, $class);
}

=head2 Video::FourCC::Info->describe( $fourcc )

This is really just a shortcut to grab the short description of a codec given
a Four Character Code as input. Note that this is a class method, not an
object method.

Example code:

  my $codec_desc = Video::FourCC::Info->describe('DIV3');

Internally, this method creates a temporary object and returns the
description, destroying the object due to falling out of scope. If you already
have a C<Video::FourCC::Info> object, then the B<description> accessor will
provide better performance.

Note, that just like C<new>, this class method may throw an exception if the
Four Character Code does not exist in the database.

Remember that this value could be C<undef> if the information is unknown.

=cut

sub describe {
  my ($class, $fourcc) = @_;

  Carp::croak('You must call this as a class method') if ref($class);
  Carp::croak('You must specify a FourCC') unless defined($fourcc);

  my $codec;
  eval {
    $codec = $class->new($fourcc);
  };
  if ($@) {
    Carp::croak($@);
  }
  return $codec->description;
}

=head2 $codec->description( )

This returns the short description of the codec. It may be C<undef> if there
is no description in the database.

Example code:

  my $codec_desc = $codec->description;

Remember that this value could be C<undef> if the information is unknown.

=cut

sub description {
  my ($self) = @_;

  Carp::croak('You must call this method as an object') unless ref($self);

  return $self->{desc};
}

=head2 $codec->registered( )

This returns the short description of the codec. It may be C<undef> if there
is no description in the database.

If C<DateTime> is installed, then this will be a DateTime object. Otherwise,
it will simply be a string in the format C<yyyy-mm-dd>.

Example code:

  my $registered = $codec->registered;

Remember that this value could be C<undef> if the information is unknown.

=cut

sub registered {
  my ($self) = @_;

  Carp::croak('You must call this method as an object') unless ref($self);

  return $self->{regdate};
}

=head2 $codec->owner( )

This returns the name of the corporation or other entity that owns the
FourCC. Generally, this seems to be an ad-hoc standard, so it's a listing
of the first entity known to use the given FourCC.

Example code:

  my $owner_name = $codec->owner;

Remember that this value could be C<undef> if the information is unknown.

=cut

sub owner {
  my ($self) = @_;

  Carp::croak('You must call this method as an object') unless ref($self);

  return $self->{owner};
}

=head2 $codec->code( )

This returns the Four Character Code corresponding to the current
C<Video::FourCC::Info> object.

Example code:

  my $fourcc = $codec->fourcc;

=cut

sub code {
  my ($self) = @_;

  Carp::croak('You must call this method as an object') unless ref($self);

  return $self->{fourcc};
}

=head1 AUTHOR

Jonathan Yu E<lt>frequency@cpan.orgE<gt>

=head2 CONTRIBUTORS

Your name here ;-)

=head1 ACKNOWLEDGEMENTS

=over

=item * Thanks to Allen Day E<lt>allenday@ucla.eduE<gt> and Benjamin R. Ginter
E<lt>bginter@asicommunications.comE<gt>, developers of Video::Info, which
inspired the creation of this module.

=back

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Video::FourCC::Info

You can also look for information at:

=over

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Video-FourCC-Info>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Video-FourCC-Info>

=item * Search CPAN

L<http://search.cpan.org/dist/Video-FourCC-Info>

=item * CPAN Request Tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Video-FourCC-Info>

=item * CPAN Testing Service (Kwalitee Tests)

L<http://cpants.perl.org/dist/overview/Video-FourCC-Info>

=back

=head1 FEEDBACK

Please send relevant comments, rotten tomatoes and suggestions directly to the
maintainer noted above.

If you have a bug report or feature request, please file them on the CPAN
Request Tracker at L<http://rt.cpan.org>. If you are able to submit your bug
report in the form of failing unit tests, you are B<strongly> encouraged to do
so. Regular bug reports are always accepted and appreciated via the CPAN bug
tracker.

=head1 SEE ALSO

L<Video::Info>, a module for extracting information like the Four Character
Code from arbitrary files.

=head1 CAVEATS

=head2 KNOWN BUGS

There are no known bugs as of this release.

=head2 LIMITATIONS

=over

=item *

This module has not been tested very thoroughly with Unicode.

=back

=head1 DATA SOURCE

The FourCC database of owner and descriptions come from data extracted from
GSpot v2.70a, a freeware Codec Information utility. The registration dates
come courtesy of Microsoft Corporation, accessed online at:
L<http://msdn.microsoft.com/en-us/library/ms867195.aspx#fourcccodes>

=head1 LICENSE

Copyright (C) 2009 by Jonathan Yu <frequency@cpan.org>

This package is distributed under the same terms as Perl itself. At time of
writing, this means that you are entitled to enjoy the covenants of, at your
option:

=over

=item 1

The Free Software Foundation's GNU General Public License (GPL), version 2 or
later; or

=item 2

The Perl Foundation's Artistic License, version 2.0 or later

=back

=head1 DISCLAIMER OF WARRANTY

This software is provided by the copyright holders and contributors "AS IS"
and ANY EXPRESS OR IMPLIED WARRANTIES, including, but not limited to, the
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED.

In no event shall the copyright owner or contributors be liable for any
direct, indirect, incidental, special, exemplary or consequential damages
(including, but not limited to, procurement of substitute goods or services;
loss of use, data or profits; or business interruption) however caused and on
any theory of liability, whether in contract, strict liability or tort
(including negligence or otherwise) arising in any way out of the use of this
software, even if advised of the possibility of such damage.

=cut

1;
