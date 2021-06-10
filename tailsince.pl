#!/usr/bin/env perl
my $VERSION = '0.1';

#use strict;
use warnings;
use diagnostics; # debugging

use Data::Dumper;
use Getopt::Long qw(HelpMessage VersionMessage);
use Pod::Usage;
use DateTime; # for time conversions and calculations
use Env; # to cache timezone
use open IN => ':reverse'; # for reading files in reverse

my $now = DateTime->now;

# default time delta is 15 minutes
my $delta_value = '15';
my $delta_unit = 'minutes';
my @delta_units_list = qw/seconds minutes hours/;
my $ipposition = 0;
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
  'delta=i' => \$delta_value,
  'timeunit=s' => \$delta_unit,
  'iplimit=i' => \(my $iplimit = 10),
  'scriptlimit=i' => \(my $scriptlimit = 10),
  'vhostlimit=i' => \(my $vhostlimit = 10),
  'help' => sub { HelpMessage(0) },
  'version' => sub { VersionMessage(0) }
  ) or HelpMessage(1);


#my $reference = 1506496800;
my $reference = DateTime->now->subtract( $delta_unit => $delta_value );
print "$reference\n";
unless (@ARGV) {
  print "Need at least one file\n";
  HelpMessage(1);
}
unless ( $delta_unit =~ /seconds|minutes|hours/ ) {
  print "Delta unit should be one of the following: @delta_units_list\n";
  HelpMessage(1);
}

my @filelist = @ARGV;

sub topips {
  my (@toplist, %ip);
  map $ip{(split)[$ipposition]}++, @_;
  @toplist = map "$ip{$_} $_\n", sort {$ip{$b} <=> $ip{$a}} keys %ip;
  my $topx = $iplimit - 1;
  return @toplist[0..$topx]; # can this be shortened?
}

foreach my $file (@filelist) {
  open(my $fh, "<", $file) or die "Could not open $file\n";
  my (@timestamp, @fixedtimestamp, $epochtimestamp, @tail, %delta, @topxips);
  while (<$fh>) {
    @timestamp = split /[][]/; # remove square brackets from the timestamp
    @fixedtimestamp = split /\/|:| /, $timestamp[1];
    $epochtimestamp = DateTime->new( year => $fixedtimestamp[2],
                                      month => $month_abbr{"$fixedtimestamp[1]"},
                                      day => $fixedtimestamp[0],
                                      hour => $fixedtimestamp[3],
                                      minute => $fixedtimestamp[4],
                                      second => $fixedtimestamp[5],
                                      time_zone => $fixedtimestamp[6],
                                     );
   # print $reference->epoch . " " . $epochtimestamp->epoch,"\n";
  } continue {
    last if ( $epochtimestamp->epoch lt $reference->epoch );
    unshift @tail, $_;
    close ARGV if eof;
  }
  #my @{$file} = <$fh>;
  #unless (@{$file}tail) { die "No tail";}
  #print @tail[0..2];
  print "@{$file}\n";
  #my @g = @{grep {/\.php/} @tail};
  #print @g;
  #@t = &topips(grep {/\.php/} @tail);
  #print @t;
}

__END__
=head1 NAME

sgan - analyze logs based

=head1 SYNOPSIS

  --delta,-d         Set time shift/delta backwards in time unit for analyzing the logs, integer, default is 15 (minutes)
  --timeunit,-t      Set the time unit for the lookback (default is minutes), can be seconds/minutes/hours
  --iplimit,-i       Set the max top IPs (default is 10)
  --scriptlimit,-s   Set the max top scripts (default is 10)
  --vhostlimit,-v    Set the max top vhosts (default is 10)
  --help,-h          Print this help

=head2 --version

VERSION 0.02

=cut