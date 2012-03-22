#
#                             IP-STB Project
#                   ---------------------------------
#
# Copyright (C) 2009 NXP Semiconductors B.V.
# All Rights Reserved.
#
# Filename: PrjList.pm
#
# Reads in prjlist.txt file.
#
# Rev Date       Author      Comments
#-------------------------------------------------------------------------------
#   1 20080212   batelaan    Initial
#   2 20090119   batelaan    Add dirs method.

package SDE2::PrjList;
use EnvVar;
use Msg;
use strict;

################################################################################
sub new {
  my ($class, $file) = @_;
  my $fileName = $file; # for error message
  if (!defined $file) {
    if (exists $ENV{_TMPROJECT}) {
      $file = "$ENV{_TMPROJECT}/prjlist.txt";
      $fileName = '$_TMPROJECT/prjlist.txt';
    } elsif (exists $ENV{_TMROOT}) {
      $file = "$ENV{_TMROOT}/project/prjlist.txt";
      $fileName = '$_TMROOT/project/prjlist.txt';
    }
  }

  my $self = {
    'file' => $file,
    'typeOfCi' => {},
    'projDirs' => [],
  };
  bless $self, $class;

  local *F;
  if (!open(F, "< $file")) {
    die "$!: $fileName\n";
  }

  my $line;
  my @projDirs = ();
  my $projDir;
  while (defined ($line = <F>)) {
    next if $line =~ /^\s*#/;
    chomp $line;
    $projDir = $line;
    $projDir =~ s/^\s+//;
    $projDir =~ s/\s+$//;
    next unless ($projDir =~ /\S/);
    $projDir = EnvVar::envVarExpand($projDir, "$file:$.");
    unshift @{$self->{projDirs}}, $projDir;
  }
  close(F);
  $self->readCIs();
  $self;
}

################################################################################
# Reads the list of components/interfaces/apps/types from the filesystem.
sub readCIs {
    my ($self) = @_;
    map {$self->readProjDir($_)} @{$self->{projDirs}};
}

################################################################################
sub readProjDir {
  my ($prjlist, $projDir) = @_;
  unless (-d $projDir) {
    warn("$!: $projDir") if debugEnabled(1);
    return;
  }
  $projDir =~ s![\\/]!/!g;
  $prjlist->readNames($projDir, "intfs");
  $prjlist->readNames($projDir, "comps");
  $prjlist->readNames($projDir, "apps");
}

################################################################################
sub dirs {
  my ($prjlist) = @_;
  return @{$prjlist->{projDirs}};
}


################################################################################
sub readNames {
  my ($prjlist, $projDir, $type) = @_;
  # get all subdirs of $projDir/$type:
  my @projDirDirs = grep {-d $_} glob("$projDir/$type/*");
  my ($dir, $name);
  foreach $dir (@projDirDirs) {
    my ($ciName) = $dir =~ m!([^/\\]+)$!;
    if (exists $prjlist->{typeOfCi}->{$ciName} && ($prjlist->{typeOfCi}->{$ciName} eq $type)) {
      warn("Multiple use with same type ($type) of directory name \"$ciName\" (\"$dir\"):\nFirst use in \"$prjlist->{cisDirs}->{$ciName}\"") if debugEnabled(1);
      next;
    }
    debug(4, "Found: $ciName => $dir");
    push @{$prjlist->{ciDirs}}, $dir;
    $prjlist->{typeOfCi}->{$ciName} = $type;
    $prjlist->{typeOfCiDir}->{$dir} = $type;
    $prjlist->{dirOfCi}->{$ciName} = $dir;
    push @{$prjlist->{ciTypesOfProjDir}->{$projDir}->{$type}}, $ciName;
  }
}

################################################################################
# Prints the instance to stdout.
sub dump {
    my ($self) = @_;
    use Data::Dumper;
    print Dumper($self);
}

################################################################################
# Internal helper function, see documentation below for how it can be used
# to test this file.
sub test {
  my ($file) = @_;
  my $prjlist = SDE2::PrjList->new($file);
  $prjlist->dump;
}

################################################################################
# Function to print the list of directories in the prjlist.txt file.
sub printDirs {
  my ($file) = @_;
  my $prjlist = SDE2::PrjList->new($file);
  foreach my $dir ($prjlist->dirs()) {
    print "$dir\n";
  }
}

################################################################################
################################################################################
1;
__END__

=head1 SDE2::PrjList

Usage:
  use SDE2::PrjList;
  $prjlist = SDE2::PrjList->new();
  # or
  $prjlist = SDE2::PrjList->new($fileName);

=head2 new()

Usage:
  C<SDE2::PrjList-E<gt>new()>
  C<SDE2::PrjList-E<gt>new($fileName)>

Create a new instance.
Reads $_TMPROJECT/prjlist.txt if _TMPROJECT environment variable exists,
otherwise it reads $_TMROOT/project/prjlist.txt .
The object returned is a blessed hash:

  { file => 'the prjlist.txt file',
    projDirs => [ 'directory read from prjlist.txt', ....],
    typeOfCi => { 'ciName' => 'comps|intfs', ...},
    typeOfCiDir => { 'ciDir' => 'comps|intfs', ...},
    dirOfCi => { 'ciName' => 'ci directory', ... },
    ciTypesOfProjDir => {
      'directory read from prjlist.txt' => {
        'comps' => ['ciName', ...],
         intfs => ['ciName', ...]
       },
       ...
    }
  }

=head1 Testing

To test this module, run:

  cd $PRJROOT
  - perl -MSDE2::PrjList -e 'SDE2::PrjList::printDirs();'
  - perl -MSDE2::PrjList -e 'SDE2::PrjList::test("sde2/project/prjlist.txt");'
  - perl -MSDE2::PrjList -e 'SDE2::PrjList::test();'
    This uses $_TMPROJECT/prjlist.txt if $_TMPROJECT is defined,
    otherwise $_TMROOT/project/prjlist.txt file .
