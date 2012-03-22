# See end of file for documenation in POD format.

package Msg;
use strict;
use Exporter;
use vars qw(@ISA @EXPORT $globalDebugLevel $errors $warnings %debugLevel);
use Carp;
@ISA = qw(Exporter);
@EXPORT = qw(checkNumArgs warn error fatal fatalMaybe fatalCall
  debugx debug debugEnabled debugLevel globalDebugLevel);

################################################################################
BEGIN {
    $globalDebugLevel = 0;
    foreach my $arg (@main::ARGV) {
        $globalDebugLevel = $1 if $arg =~ /^--debug=(\d+)$/;
    }
    $errors = 0; # count
    $warnings = 0; # count
}

sub import {
  my $pkg = caller;
  #print STDERR "Msg::import: @_ from package $pkg\n";
  Msg->export_to_level(1, $pkg, @EXPORT);
  $debugLevel{$pkg} = 99999 unless exists $debugLevel{$pkg};
}

sub checkNumArgs {
  my ($argsRA, $minArgs, $maxArgs) = @_;
  if (scalar(@$argsRA) < $minArgs) {
    fatalCall(1, $argsRA, "too few arguments:\n" .
	      (((defined $maxArgs) && ($minArgs == $maxArgs)) ? "exactly" : "at least") .
	      " $minArgs expected.");
  }
  if ((defined $maxArgs) && (($maxArgs == -1) || (scalar(@$argsRA) > $maxArgs))) {
    fatalCall(1, $argsRA, "too many arguments:\nat most $maxArgs expected.");
  }
}

sub warn {
  print STDERR "\nWarning: @_\n";
  $warnings++;
}

sub error {
  print STDERR "\n**ERROR: @_\n";
  $errors++;
}

sub fatal {
  $errors++;
  die "**FATAL: @_\n";
}

sub fatalMaybe {
  my $isNotFatal = shift;
  if ($isNotFatal) {
    $errors++;
    carp "\n**ERROR: @_\n";
  } else {
    die "\n**FATAL: @_\n";
  }
}

sub fatalCall {
  my $callerLevel = shift;
  my $argsRA = shift;
  my @callerInfo = caller($callerLevel + 1);
  #my $pkg = $callerInfo[0];
  my $fileName = $callerInfo[1];
  my $lineNo = $callerInfo[2];
  my $funcName = $callerInfo[3];
  #$funcName =~ s/^\Q$pkg\E:://;
  fatal("$fileName:$lineNo:\n$funcName(" . join(", ", @$argsRA) . "): ", "\n@_", @_);
}

sub debugx {
  checkNumArgs(\@_, 2);
  my ($level, @args) = @_;
  my $pkg = caller;
  my $debugLevel = exists $debugLevel{$pkg} ? $debugLevel{$pkg} : $globalDebugLevel;
  if ($debugLevel >= $level && $globalDebugLevel >= $level) {
    print STDERR "[$level] @args\n";
  }
}

sub debug {
  checkNumArgs(\@_, 1);
  my (@args) = @_;
  if ($globalDebugLevel != 0) {
    print STDERR "@args\n";
  }
}

sub debugEnabled {
  checkNumArgs(\@_, 1, 1);
  my ($level) = @_;
  my $pkg = caller;
  $level >= $globalDebugLevel or (exists($debugLevel{$pkg}) && $level >= $debugLevel{$pkg});
}

sub globalDebugLevel {
  my ($newLevel) = @_;
  checkNumArgs(\@_, 0, 1);
  return $globalDebugLevel if @_ == 0;
  fatal("globalDebugLevel: not an integer ($newLevel)") unless $newLevel =~ /^\d+$/;
  $globalDebugLevel = $newLevel;
}

sub debugLevel {
  my ($newLevel) = @_;
  checkNumArgs(\@_, 0, 1);
  my $pkg = caller;
  return $debugLevel{$pkg} if @_ == 0;
  fatal("debugLevel: not an integer ($newLevel)") unless $newLevel =~ /^\d+$/;
  $debugLevel{$pkg} = $newLevel;
}

1;

__END__

=head1 Msg

Usage: use Msg; BEGIN { debugLevel(LEVEL); }

LEVEL is an integer and indicates the debug level for the importing package.

The Msg.pm module checks @ARGV for a --debug=(\d+) entry, and if found
sets $globalDebugLevel to this.

=head2 fatal

Usage: C<fatal(args...)>

Prints a fatal message  and exists the program.
Args are passed to the Perl print subroutine.

=head2 debugx

Usage: C<debugx($level, args...)>

Prints a debug message (on STDERR) if the active debug level is >= $level.
The active debug level is determined as follows:
- The user package specified its own level using a call to debugLevel.
- otherwise it is the globalDebugLevel.
Args are passed to the Perl print subroutine.

=head2 debug

Usage: C<debug(args...)>

Prints a debug message using STDERR if the debugging is enabled. Args are passed to
the Perl print subroutine.
