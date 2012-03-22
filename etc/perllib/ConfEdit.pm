#
#                             IPSTB Project
#                   ---------------------------------
#
# Copyright (C) 2009 NXP B.V.,
# All Rights Reserved.
#
# Filename: ConfEdit.pm
#
#
# Rev Date        Author      Comments
#-------------------------------------------------------------------------------
#   1 20081010    batelaan    Initial
#   2 20090310    batelaan    Cope better with handwritten files.
#   3 20090330    batelaan    Check env var CONFEDIT_DEBUG.
#                             Correct trailing whitespace handling for SET_STRING
#                             if value is empty. Add SET_STRING_EVAL.
#   4 20090616    batelaan    Add SET_INT

# File: ConfEdit.pm
# Perl module for editing Linux/Buildroot/Project config files.
# Example usage at end of this file.
# See also the CONFEDIT_* macros ../util.mk
#
# If environment variable CONFEDIT_DEBUG is set, then
# print out debugging information.

package ConfEdit;
use strict;
use vars qw(@ISA @EXPORT);
use Carp;
use constant ATSTART => 1;
use constant ATEND   => 0;

my $debug = exists $ENV{'CONFEDIT_DEBUG'};

################################################################################

sub main::run {
  my $cfg;
  {
    local $/;
    $cfg = <>;
  }

  my $line;
  while ($line = <main::DATA>) {
    next if $line =~ /^\s*#/;  # skip comment lines
    next unless $line =~ /\S/; # skip blank lines
    chomp $line;
    print STDERR "line = $line\n" if $debug;
    $line =~ s/\s+$//; # trim trailing space
    $line =~ s/^\s+//; # trim leading space
    croak "Huh: $line" unless $line =~ s/^(\w+)\s*//;
    my $cmd = $1;
    print STDERR "  cmd = $cmd\n" if $debug;
    eval { package ConfEdit; no strict 'refs'; $cfg = $cmd->($cfg, $line); };
    croak $@ if $@;
  }
  print $cfg;
}

################################################################################
sub calcNewValue {
  my ($oldValue, $newValueExpr, $eval, $valueType) = @_;
  my $newValue;
  if ($eval) {
    # First remove "" around old value:
    local $_ = eval $oldValue;
    croak $@ if $@;
    eval $newValueExpr;
    croak $@ if $@;
    if ($valueType eq 'string') {
      $newValue = "\"$_\"";
    } elsif ($valueType eq 'int') {
      $newValue = "$_";
    } else {
      croak "Incorrect valueType (not string or int): $valueType";
    }
  } else {
    $newValue = $newValueExpr;
  }
  return $newValue;
}

################################################################################
sub replaceOrAdd {
  my ($atStart, $cfg, $var, $value, $eval, $valueType) = @_;
  print STDERR "replaceOrAdd $var=", (defined $value ? $value : "<unset>"), "\n" if $debug;
  my $newValue;

  # 3 cases:
  # - it is currently unset
  # - it is currently set
  # - it is curently not present at all

  # Case: it is currently unset
  if ($cfg =~ m{^# $var is not set}m) {
    $newValue = calcNewValue(undef, $value, $eval, $valueType);
    if (defined $newValue) {
      $cfg =~ s{^# $var is not set}{$var=$newValue}m;
      print STDERR "Replaced '$var is not set' with $newValue\n" if $debug;
    } else {
      print STDERR "$var already unset\n" if $debug;
    }
  } elsif ($cfg =~ m{^$var=(.*)}m) {
    # Case: it is currently set
    my $oldValue = $1;
    $newValue = calcNewValue($oldValue, $value, $eval, $valueType);
    if (defined($newValue)) {
      if ($oldValue eq $newValue) {
        print STDERR "$var already set to $newValue\n" if $debug;
      } else {
        $cfg =~ s{^$var=(.*)}{$var=$newValue}m;
        print STDERR "Replaced $var=$oldValue with $newValue\n" if $debug;
      }
    } else {
      print STDERR "Unsetting $var (oldValue was $oldValue)\n" if $debug;
      $cfg =~ s{^$var=(.*)}{# $var is not set}m;
    }
  } else {
    # Case: it is curently not present at all
    $newValue = calcNewValue(undef, $value, $eval, $valueType);
    my $addition;
    if (defined $newValue) {
      $addition = "$var=$newValue\n";
      print STDERR "Appended $var=$newValue\n" if $debug;
    } else {
      $addition = "# $var is not set\n";
      print STDERR "Appended $var is not set\n" if $debug;
    }
    if ($atStart) {
      $cfg = $addition . $cfg;
    } else {
      $cfg .= $addition;
    }
  }
  return $cfg;
}

################################################################################
sub SET_RAW {
  my ($cfg, $args) = @_;
  my ($var, $value) = $args =~ /^(\w+) (.*)/;
  return replaceOrAdd ATEND, $cfg, $var, $value, 0, 'not_applicable';
}

################################################################################
sub SET {
  my ($cfg, $var) = @_;
  return replaceOrAdd ATEND, $cfg, $var, 'y', 0, 'not_applicable';
}

################################################################################
sub SET_M {
  my ($cfg, $var) = @_;
  return replaceOrAdd ATEND, $cfg, $var, 'm', 0, 'not_applicable';
}

################################################################################
sub UNSET {
  my ($cfg, $var) = @_;
  return replaceOrAdd ATEND, $cfg, $var, undef, 0, 'not_applicable';
}

################################################################################
sub SET_STRING {
  my ($cfg, $args) = @_;
  my ($var, $value) = $args =~ /^(\w+) *(.*)/;
  return replaceOrAdd ATEND, $cfg, $var, "\"$value\"", 0, 'not_applicable';
}

################################################################################
sub SET_INT {
  my ($cfg, $args) = @_;
  my ($var, $value) = $args =~ /^(\w+) *(.*)/;
  return replaceOrAdd ATEND, $cfg, $var, "$value", 0, 'int';
}

################################################################################
sub SET_STRING_EVAL {
  my ($cfg, $args) = @_;
  my ($var, $value) = $args =~ /^(\w+) *(.*)/;
  return replaceOrAdd ATEND, $cfg, $var, $value, 1, 'string';
}

################################################################################
sub SET_INT_EVAL {
  my ($cfg, $args) = @_;
  my ($var, $value) = $args =~ /^(\w+) *(.*)/;
  return replaceOrAdd ATEND, $cfg, $var, $value, 1, 'int';
}

################################################################################
sub CLEAR_STRING {
  my ($cfg, $var) = @_;
  return replaceOrAdd ATEND, $cfg, $var, '""', 0, 'not_applicable';
}

################################################################################
sub DELETE {
  my ($cfg, $var) = @_;
  print STDERR "DELETE $var\n" if $debug;
  if ($cfg =~ s{^# $var is not set\n}{}m) {
    print STDERR "Deleted '$var is not set'\n" if $debug;
  } elsif ($cfg =~ s{^$var=(.*)\n}{}m) {
    my $oldValue = $1;
    print STDERR "Deleted '$var=$oldValue'\n" if $debug;
  }
  return $cfg;
}

################################################################################
sub splitOnVar {
  my ($cfg, $var) = @_;
  my ($head, $tail) = $cfg =~ m{^(.*\n(?:# $var is not set|$var=.*?)\n)(.*)$}s;
  if (defined $tail) {
    #my ($h) = $head =~ /^(.*)\Z/m;
    #my $t = substr $tail,  0, 50;
    #print STDERR "\nsplitOnVar $var:\nHead: $h\nTail: $t\n\n";
    return ($head, $tail);
  } else {
    croak "Could not find entry for $var\n";
  }
}

################################################################################
sub ADD_AFTER_RAW {
  my ($cfg, $args) = @_;
  my ($afterVar, $var, $value) = $args =~ /^(\w+) (\w+) (.*)/;
  my ($head, $tail) = splitOnVar($cfg, $afterVar);
  $tail = replaceOrAdd ATSTART, $tail, $var, $value, 0, 'not_applicable';
  $cfg = $head . $tail;
  return $cfg;
}

################################################################################
sub ADD_AFTER_SET {
  my ($cfg, $args) = @_;
  my ($afterVar, $var) = $args =~ /^(\w+) (\w+)/;
  my ($head, $tail) = splitOnVar($cfg, $afterVar);
  $tail = replaceOrAdd ATSTART, $tail, $var, 'y', 0, 'not_applicable';
  $cfg = $head . $tail;
  return $cfg;
}

################################################################################
sub ADD_AFTER_UNSET {
  my ($cfg, $args) = @_;
  my ($afterVar, $var) = $args =~ /^(\w+) (\w+)/;
  my ($head, $tail) = splitOnVar($cfg, $afterVar);
  $tail = replaceOrAdd ATSTART, $tail, $var, undef, 0, 'not_applicable';
  $cfg = $head . $tail;
  return $cfg;
}

################################################################################
1;

__END__
# This is an example script using this module:

use ConfEdit;
run();
__DATA__
SET_STRING CONFIG_LOCALVERSION .full.dev
SET_STRING_EVAL CONFIG_NAME $_ .= "_custom" unless /_custom/;
UNSET CONFIG_MTD_PHYSMAP
DELETE CONFIG_MTD_PHYSMAP_START
DELETE CONFIG_MTD_PHYSMAP_LEN
DELETE CONFIG_MTD_PHYSMAP_BANKWIDTH
SET CONFIG_MTD_NAND
ADD_AFTER_UNSET CONFIG_MTD_NAND CONFIG_MTD_NAND_VERIFY_WRITE
ADD_AFTER_UNSET CONFIG_MTD_NAND_VERIFY_WRITE CONFIG_MTD_NAND_ECC_SMC
ADD_AFTER_UNSET CONFIG_MTD_NAND_ECC_SMC CONFIG_MTD_NAND_MUSEUM_IDS
ADD_AFTER_SET CONFIG_MTD_NAND_MUSEUM_IDS CONFIG_MTD_NAND_IDS
ADD_AFTER_UNSET CONFIG_MTD_NAND_IDS CONFIG_MTD_NAND_DISKONCHIP
ADD_AFTER_UNSET CONFIG_MTD_NAND_DISKONCHIP CONFIG_MTD_NAND_NANDSIM
ADD_AFTER_SET CONFIG_MTD_NAND_NANDSIM CONFIG_MTD_NAND_PLATFORM
ADD_AFTER_UNSET CONFIG_MTD_NAND_PLATFORM CONFIG_MTD_ALAUDA
SET CONFIG_MTD_BLOCK_ROBBS
UNSET CONFIG_SERIAL_PNX8XXX_UART0
DELETE CONFIG_SERIAL_PNX8XXX_TTYS0
SET CONFIG_SERIAL_PNX8XXX_UART1
SET CONFIG_SERIAL_PNX8XXX_TTYS1
SET CONFIG_SERIAL_PNX8XXX_CONSOLE
UNSET CONFIG_DVB_TDA10021
UNSET CONFIG_DVB_TDA10023
UNSET CONFIG_DVB_TDA1004X
UNSET CONFIG_DVB_TDA10048
UNSET CONFIG_DVB_TDA10086
UNSET CONFIG_DVB_TDA826X
UNSET CONFIG_DVB_TDA827X
UNSET CONFIG_DVB_TDA18211
UNSET CONFIG_DVB_TD1316
UNSET CONFIG_DVB_MAX3541

# This would set it to 1024
SET_INT CONFIG_VIDEO_ES_BUFSIZE 1024

# This would double its value:
SET_INT_EVAL CONFIG_AUDIO_ES_BUFSIZE $_ *= 2
