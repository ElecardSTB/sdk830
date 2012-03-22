#
#                             IP-STB Project
#                   ---------------------------------
#
# Copyright (C) 2008 NXP Semiconductors B.V.
# All Rights Reserved.
#
# Filename: CIReleaseSpec.pm
#
# See end of file for documenation in POD format.
#
# Rev Date        Author      Comments
#-------------------------------------------------------------------------------
#   1 20080130    batelaan    Initial
#   2 20080213    batelaan    Add validateFile.
#   3 20080214    batelaan    Suppress msg and exit(0) if no problems found.
#   4 20080619    batelaan    Use FileHandle
#   5 20081029    batelaan    Add printIsFrozenCI

package SDE2::CIReleaseSpec;
use strict;
use FileHandle;

# Used for keep/purge rules.
use constant keep => 0;
use constant purge => 1;
use constant missingRuleError => 2;

my @releaseTypes = qw(exclude library headers source);
my $dirAttrRX = '(nodefault|exclude|library|headers|source)';
my $ciTypeRX = '(exclude|library|headers|source)';

my $helptext = <<'EOT';

The file format has multiple of the following sections:
<SDE2_DIRECTORY>: (nodefault|<TYPE>)
<tab><TYPE>:
<tab><tab><CI_NAME>
<tab><tab><CI_NAME>
<tab><tab>...
<tab><TYPE>:
<tab><tab><CI_NAME>
<tab><tab><CI_NAME>
<tab><tab>...
<tab>...

SDE2_DIRECTORY is a path to a comps or intfs SDE2 directory, relative
to a workarea root directory.
CI_NAME is the name of a SDE2 CI (component or interface).

TYPE specifies what is released of a CI,
and is described in the following table.
lib/* inc/* src/* indicate parts of a SDE2 component.
  TYPE    | lib/* | inc/* | src/* | Description
  --------+-------+-------+-------+--------------------------------------------
  exclude |   -   |   -   |   -   | Excluded from the release
  library |  yes  |   -   |   -   | Internal API, only release compiled library
  headers |  yes  |  yes  |   -   | Callable by customers, no source code
  source  |  yes  |  yes  |  yes  | Fully rebuildable by customers (except tst).

If an <SDE2_DIRECTORY> has nodefault after its name, then ALL
components/interfaces must be specified explicitly. It is an error
if they are not all listed.

Notes:
- for library and headers release type the bin directory is also included.
EOT

################################################################################
# Create a new instance.
sub new {
    my ($class) = @_;
    my $self = {
        'dirs' => [],
        'ci2type' => {},
        'dirHash' => {},
    };
    bless $self, $class;
    $self;
}

################################################################################
# Return list of release types.
# See @releaseTypes.
sub releaseTypes {
  return @releaseTypes;
}

################################################################################
# Prints the instance to stdout.
sub dump {
    my ($self) = @_;
    use Data::Dumper;
    print Dumper($self);
}

################################################################################
sub readFromFile {
    my ($self, $path) = @_;
    my $fh = new FileHandle;
    unless ($fh->open($path)) {
        die("$!: $path");
    }
    $self->readFromFileHandle($fh, $path);
}

################################################################################
sub readFromFileHandle {
    my ($self, $fh, $path) = @_;
    $self->{file} = $path;
    my $ci2type = $self->{ci2type};
    my $line;
    my $lineNo = 0;
    eval {
      # Read SDE2 directory sections:
    PARSE_DIR:
      while (defined ($line = <$fh>)) {
        $lineNo++;
        #print STDERR "$lineNo: $line\n";
        next if $line =~ /^\s*#/; # skip comment lines
        next if $line !~ /\S/; # skip whitespace only lines
        my ($dir, $attr) = $line =~ /^([^:]+):\s* $dirAttrRX\s*$/;
        if (!defined $attr) {
          die("$path:$lineNo: $line");
        }
        #print "Directory: $dir ($attr)\n";
        my $dirObject = {dirname=>$dir, attr=>$attr};
        push @{$self->{dirs}}, $dirObject;
        $self->{dirHash}->{$dir} = $dirObject;

        # Read sections starting with lines in the format: <tab><ciTypeRX>:
      PARSE_TYPE:
        while (defined ($line = <$fh>)) {
          $lineNo++;
          #print STDERR "$lineNo: $line\n";
          next if $line =~ /^\s*#/; # skip comment lines
          next if $line !~ /\S/; # skip whitespace only lines
          my ($type) = $line =~ /^\t$ciTypeRX:\s*$/;
          if (!defined $type) {
            redo PARSE_DIR;
          }
          #print "\tType: $type\n";
          my $typeObject = {type=>$type, cis=>[]};
          $dirObject->{$type} = $typeObject;

          # Read lines in the format: <tab><tab><ciName>
          while (defined ($line = <$fh>)) {
            $lineNo++;
            #print STDERR "$lineNo: $line\n";
            next if $line =~ /^\s*#/; # skip comment lines
            next if $line !~ /\S/; # skip whitespace only lines
            my ($ci) = $line =~ /^\t\t(\S+)\s*$/;
            if (!defined $ci) {
              redo PARSE_TYPE;
            }
            push @{$typeObject->{cis}}, $ci;
            $ci2type->{$ci} = $type;
            #print "		CI: $ci type: $type\n";
          }
        }
      }
    };
    die "$path:$lineNo: $line\nPARSE ERROR!\n$helptext\n" if $@;
    $fh->close;
    $self;
}

################################################################################
sub validate {
  my ($self) = @_;
  $self->{warnings} = 0;
  foreach my $dirObject (@{$self->{dirs}}) {
    my $dirName = $dirObject->{dirname};
    #print "Checking rules for $dirName\n";
    my $defaultAttr = $dirObject->{attr};
    my %statusForCiDirsOnDisk;
    # Initialise status of all directories contained in $dirName:
    foreach my $ciDir (glob("$dirName/*")) {
      next unless -d $ciDir;
      $statusForCiDirsOnDisk{$ciDir} = '';
    }
    #print "  $dirName has ", scalar(keys %statusForCiDirsOnDisk), " subdirs\n";
    #print "  $dirName has ", join(' ', keys %statusForCiDirsOnDisk), " subdirs\n";
    foreach my $releaseType (@releaseTypes) {
      foreach my $typeObject ($dirObject->{$releaseType}) {
        foreach my $ci (@{$typeObject->{cis}}) {
          #print "    Checking CI $ci (release type $releaseType)\n";
          if (!exists $statusForCiDirsOnDisk{"$dirName/$ci"}) {
            $self->validateMsg("**WARNING: CI \"$dirName/$ci\" in rules file does not exist in filesystem.\n");
          }
          $statusForCiDirsOnDisk{"$dirName/$ci"} = $typeObject->{type};
        }
      }
    }
    if ($defaultAttr eq 'nodefault') {
      foreach my $ciDirOnDisk (sort(keys(%statusForCiDirsOnDisk))) {
        if ($statusForCiDirsOnDisk{$ciDirOnDisk} eq '') {
          $self->validateMsg(
            "**WARNING: CI \"$ciDirOnDisk\" in filesystem has no rule in spec file\n",
            "         (and \"$dirName\" has 'nodefault' attribute).\n");
        }
      }
    }
  }
  if ($self->{warnings} != 0) {
    print "$self->{warnings} discrepanc",
    ($self->{warnings} == 1 ? "y" : "ies"),
    " found for CI release spec file \"$self->{file}\".\n\n";
  }
  $self->{warnings};
}

sub validateMsg {
  my ($self) = shift;
  if ($self->{warnings} == 0) {
    print "\nValidating CI release spec file \"$self->{file}\"...\n";
  }
  print @_;
  $self->{warnings}++;
}

################################################################################
sub validateFile {
  my ($file) = @_;
  my $spec = SDE2::CIReleaseSpec->new();
  $spec->readFromFile($file);
  exit($spec->validate() == 0 ? 0 : 1);
}

################################################################################
sub getCIRelType {
  my ($self, $ciPath) = @_;
  my ($dir, $ci) = $ciPath =~ m!^(.*)/([^/]+)$!;
  if (!defined $dir) {
    $dir = ".";
    $ci = $ciPath;
  }
  my $type = $self->{ci2type}->{$ci};
  if (defined $type) {
    #print STDERR "CI $ciPath (dir $dir, name $ci) has explicitly specified type $type\n";
    return $type;
  }
  my $dirObject = $self->{dirHash}->{$dir};
  my $defaultAttr = $dirObject->{attr};
  if ($defaultAttr eq 'nodefault') {
    #print STDERR "CI $ciPath (dir $dir, name $ci) was not found!\n";
    return undef;
  }
  #print STDERR "CI $ciPath (dir $dir, name $ci) has default type $defaultAttr\n";
  return $defaultAttr;
}

################################################################################
sub printIsFrozenCI {
  my ($file, $ci) = @_;
  my $spec = SDE2::CIReleaseSpec->new();
  $spec->readFromFile($file);
  my $type = $spec->getCIRelType($ci);
  if (defined $type) {
    print ($type eq 'source' ? "false\n" : "true\n");
    exit(0);
  } else {
    print STDERR "CIReleaseSpec: spec file $file\n  does not specify CI $ci\n";
    exit(1);
  }
}

################################################################################
# Internal helper function, see file header for how it can be used
# to test this file.
sub test {
  my ($file) = @_;
  my $spec = SDE2::CIReleaseSpec->new();
  $spec->readFromFile($file);
  $spec->dump;
  $spec->validate();
}
################################################################################
1;
__END__

=head1 SDE2::CIReleaseSpec

Usage:
  use SDE2::CIReleaseSpec;
  $spec = SDE2::CIReleaseSpec->new();
  $spec->readFromFile($fileName);

CI Release Spec file handling.

It creates a spec object from a file, with the following structure:
  {
    'file' => 'etc/ci_release_stb225.spec',
    'dirs' => [
                {
                  'dirname' => '<SDE2_DIRECTORY>',
                  'attr' => '<TYPE>|nodefault',
                  '<TYPE>' => {
                                 'cis' => [
                                            '<CIName>', ...
                                          ],
                                 'type' => 'headers'
                               },
                  ...
                },
                ...
              ]
  }

=head2 $helpText

Contains the format of the CI Release Spec file.

=head2 releaseTypes()

Usage: C<releaseTypes()>

Returns list of release types, e.g. exclude library headers source.

=head2 dump()

Usage: C<$spec-E<gt>dump()>

Dumps the contents of the spec object as text. Useful for debugging.

=head2 readFromFile()

Usage: C<$spec-E<gt>readFromFile($fileName)>

Parses $fileName, and stores the specification in the spec object.
Calls die with an error message if an error is found.
Otherwise returns self.


=head2 validate()

Usage: C<$spec-E<gt>validate()>

Checks:

- There are no CIs in the filesystem that are not matched by our rules.

- There are not CIs in the CI release spec file that do not exist in the
filesystem.

Returns: number of problems found.

=head2 validateFile()

Usage: C<validateFile($fileName)>

Load a CI release spec file, and validates it using L<validate()>.
Exits program with 0 if no errors was found.

=head1 Testing

To test this module, run:
  cd $PRJROOT
  perl -MSDE2::CIReleaseSpec -e 'SDE2::CIReleaseSpec::test("etc/ci_release_stb225.spec");'
  perl -MSDE2::CIReleaseSpec -e 'SDE2::CIReleaseSpec::validateFile("etc/ci_release_stb225.spec");'
  perl -MSDE2::CIReleaseSpec -e 'SDE2::CIReleaseSpec::printIsFrozenCI("prjfilter <etc/ci_release_stb225.spec|", "src/comps/phStbDbg");'
  perl -MSDE2::CIReleaseSpec -e 'SDE2::CIReleaseSpec::printIsFrozenCI("prjfilter <etc/ci_release_stb225.spec|", "src/mipsdsp/AudioCodecs/comps/phFAC3DEC");'
