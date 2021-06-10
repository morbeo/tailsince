#!/usr/bin/env perl
my $VERSION = '0.1';

#use strict;
use warnings;
use diagnostics; # debugging

use Getopt::Long qw(HelpMessage VersionMessage);
use Pod::Usage;
use DateTime;              # for time conversions and calculations
use Env;                   # to cache timezone

my $now = DateTime->now;

# default time delta is 15 minutes
my $delta_value = '15';
my $delta_unit = 'minutes';
my @delta_units_list = qw/seconds minutes hours/;
my %month_abbr = (
  'Jan' => '01',
  'Feb' => '02',
  'Mar' => '03',
  'Apr' => '04',
  'May' => '05',
  'Jun' => '06',
  'Jul' => '07',
  'Aug' => '08',
  'Sep' => '09',
  'Oct' => '10',
  'Nov' => '11',
  'Dec' => '12',
);

GetOptions(
  'delta=i'       => \$delta_value,
  'timeunit=s'    => \$delta_unit,
  'help'          => sub { HelpMessage(0) },
  'version'       => sub { VersionMessage(0) }
  ) or HelpMessage(1);

my $reference = DateTime->now->subtract( $delta_unit => $delta_value );
unless (@ARGV) {
  print "Need at least one file\n";
  HelpMessage(1);
}
unless ( $delta_unit =~ /seconds|minutes|hours/ ) {
  print "Delta unit should be one of the following: @delta_units_list\n";
  HelpMessage(1);
}

my @filelist = @ARGV;

foreach my $file (@filelist) {
  open(my $current_file, "-|","tac", $file) or die "Could not open $file\n"; # open file with tac so it is in reverse
  my (@timestamp, @fixedtimestamp, $epochtimestamp, @tail, %delta);
  while (<$current_file>) {
    @timestamp      = split /[][]/; # remove square brackets from the timestamp
    @fixedtimestamp = split /\/|:| /, $timestamp[1];
    $epochtimestamp = DateTime->new( year      => $fixedtimestamp[2],
                                     month     => $month_abbr{"$fixedtimestamp[1]"},
                                     day       => $fixedtimestamp[0],
                                     hour      => $fixedtimestamp[3],
                                     minute    => $fixedtimestamp[4],
                                     second    => $fixedtimestamp[5],
                                     time_zone => $fixedtimestamp[6],
                                     );
  } continue {
    last if ( $epochtimestamp->epoch lt $reference->epoch );
    unshift @tail, $_;
    close ARGV if eof;
  }
  print "@{$file}\n";
}

__END__
=head1 NAME

tailsince - output the last part of file

=head1 SYNOPSIS

  --delta,-d         Set time shift/delta backwards in time unit for analyzing the logs, integer, default is 15 (minutes)
  --timeunit,-t      Set the time unit for the lookback (default is minutes), can be seconds/minutes/hours
  --help,-h          Print this help

=head2 --version

VERSION 0.1

=cut