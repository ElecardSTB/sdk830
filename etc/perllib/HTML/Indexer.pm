#
#                             IPSTB Project
#                   ---------------------------------
#
# Copyright (C) 2008 NXP B.V.,
# All Rights Reserved.
#
# Filename: HTML/Indexer.pm
#
# Creates an index of words in HTML files.
# See also the htmlindexer shell script.
#
# Based on the cgi indexer from the O'Reilly Perl CGI Programming book.
#
# Rev Date       Author      Comments
#-------------------------------------------------------------------------------
#   1 20081022   batelaan    Initial
#   3 20081023   batelaan    Don't index output file jss-index.html
#                            Add -file option. Index the filename itself.

package HTML::Indexer;

use strict;
use File::Find;
use Getopt::Long;
#use Text::English;
use Fcntl;
use Carp;

{
  my (%word2FileIds, @words, %fileId2Name, @inputFiles, $stop_words, @wordsRanked);
  my $dir;
  my $file;
  my $exclude;
  my $case = 0;
  my $stop;
  my $numbers = 0;
  my $stem = 0;
  my $dump = 0;
  my $jssindex = 0;
  my $debug = 0;
  my $outdir = ".";
  my $rank;
  my $quiet = 0;
  my $debugFile = 0;

my %options = (
  -dir => \$dir,
  -file => \$file,
  -exclude => \$exclude,
  -case => \$case,
  -stop => \$stop,
  -numbers => \$numbers,
  -stem => \$stem,
  -dump => \$dump,
  -jssindex => \$jssindex,
  -debug => \$debug,
  -quiet => \$quiet,
  -outdir => \$outdir,
  -rank => \$rank,
);

sub options {
return <<EOT;
  -dir INPUTDIR   Input directory name
  -file INPUTFILE Input file name
  -case [0|1]     Case-sensitive index
  -stop FILE      Path to stopwords file
  -rank FILE      Output file with words sorted by number of file occurances
  -numbers [0|1]  Include numbers in index
  -stem [0|1]     Stem words
  -dump[0|1]      Dump indexes
  -jssindex [0|1] Write JavaScript Search files
  -debug [0|1]    Debug mode
  -quiet [0|1]    Quiet
  -outdir DIR     Output directory
-dir or -file is required.
EOT
}

sub new {
  my $class = shift;
  my $self = {@_};
  bless $self, $class;
  my $opt;

  # extract options from arguments:
  foreach $opt (keys %$self) {
    my $optval = $self->{$opt};
    my $varRef = $options{$opt};
    croak "No such option: $opt\nOptions are: " . join(" ", keys(%options)) if !exists $options{$opt};
    #print "Setting $opt to $self->{$opt}\n";
    $$varRef = $optval;
  }

  croak("Missing -dir and/or -file") if !(defined $dir or defined $file);

  # do I want to index this file?
  sub indexFile {
    my ($name) = @_;
    return 0 if defined($exclude) && $name =~ m/$exclude/o;
    return 0 if $name =~ m{(?:^|/)jss-index.htm$};
    return 1 if $name =~ m/\.html?$/i;
    return 0;
  }

  sub run {
    my $self = shift;
    if (defined $file) {
      push @inputFiles, $file;
    }
    if (defined $dir) {
      find(
        {
          'wanted' => sub {
            if (indexFile($_)) {
              my $fname = $File::Find::name;
              $fname =~ s{^./}{};
              push @inputFiles, $fname;
            }
          },
          'preprocess' => sub { sort @_; },
        },
        $dir );
    }


    $stop_words = load_stop_words($stop) if defined $stop;

    process_files();

    if ($dump) {
      dump_indexes();
    }

    if ($jssindex) {
      write_jssindex();
    }

    if (defined $rank) {
      write_rank();
    }
    return $self;
  }

  sub dump_indexes {
    print "words: ", Dumper(\%word2FileIds);
    print "files: ", Dumper(\%fileId2Name);
  }

  sub write_rank {
    my $F;
    print "Writing $rank\n";
    open($F, ">$rank") or croak("$!: $rank");
    for my $w (@wordsRanked) {
      print $F scalar(@{$word2FileIds{$w}}), "\t", $w, "\n";
    }
    close($F);
  }

  sub write_jssindex {
    my $masterIndex;
    my $masterIndexFile = "$outdir/jss-index.htm";
    open($masterIndex, ">$masterIndexFile") or croak "$!: JSS-masterIndex.js";
    print "Writing $masterIndexFile\n";
    print $masterIndex <<EOT;
<html><head>
<script>
var base_url=\".\";
EOT

    print $masterIndex "var doc_url = [\n";
    my $file_id;
    for ( my $file_id = 0; $file_id < @inputFiles; $file_id++ ) {
      my $file = $inputFiles[$file_id];
      print $masterIndex "// $file_id\n" if $debug;
      print $masterIndex "\"$file\",\n";
    }
    print $masterIndex "];\n";

    #print $masterIndex "var doc_text = [\n";
    #foreach my $id (@fileIds) {
    #  print $masterIndex "// $id\n" if $debug;
    #  print $masterIndex "\"\",\n";
    #}
    #print $masterIndex "];\n";

    print $masterIndex "var stop_word_list = [\n";
    foreach my $stopWord (sort keys(%$stop_words)) {
      print $masterIndex "\"$stopWord\",\n";
    }
    print $masterIndex "];\n";

    my $fileId = 0;
    my $word;

    print $masterIndex "wordlist=[\n";
    foreach $word (@words) {
      print $masterIndex "\"$word\",\n";
    }
    print $masterIndex "];\n";


    print $masterIndex "doclist=[\n";
    foreach $word (@words) {
      my @files = @{$word2FileIds{$word}};
      if ($debug) {
        print $masterIndex "// Files using $word:\n";
        foreach my $file (@files) {
          print $masterIndex "// $fileId2Name{$file}\n";
        }
      }
      print $masterIndex "\"", join(',', @files), "\",\n";
    }
    print $masterIndex "];\n";

    print $masterIndex <<EOT;
//alert("End of $masterIndexFile");
</script>
<script src="jss-lib1.js"></script>
</head><body></body></html>
EOT
    close $masterIndex;
  }

  sub load_stop_words {
    my $file = shift;
    my $words = {};
    local( *INFO, $_ );

    print "Loading stop word file $file\n" if !$quiet;
    die "Cannot file stop file: $file\n" unless -e $file;

    open INFO, $file or die "$!: $file\n";
    while ( <INFO> ) {
      next if /^#/;
        $words->{lc $1} = 1 if /(\S+)/;
    }

    close INFO;
    return $words;
  }

  sub indexString {
    my ($file, $file_id, $wordsSeen, $s) = @_;
    print "  Line: $s" if $debugFile;
    $s =~ s/<script.+?<\/script>/ /gs;
    $s =~ s/<.+?>/ /gs; # Note this doesn't handle < or > in comments or js
    $s =~ tr/A-Z/a-z/ if !$case;
    $s =~ s/\&[a-z]+;/ /g;
    print "    Stripped: $s" if $debugFile;

    while ( $s =~ /([a-z\d_]{3,})\b/gi ) {
      my $word = $1;
      print "      Word: $word\n" if $debugFile && !exists($wordsSeen->{$word});
      next if $stop_words->{$word};
      next if $word =~ /^(?:\d+|0x[\da-f]+)$/i && not $numbers;
      # ( $word ) = Text::English::stem( $word ) if $stem;
      push @{$word2FileIds{$word}}, $file_id unless
        $wordsSeen->{$word}++;
    }
  }

  sub process_files {
      local( *FILE, $_ );
      local $/ = "\n\n";

      for ( my $file_id = 0; $file_id < @inputFiles; $file_id++ ) {
          my $file = $inputFiles[$file_id];
          my %seen_in_file;
          #$debugFile = $file =~ m{ejtag_tools.html$};
          if (! -T $file) {
            print "**WARNING: does not seem to be a text file: $file\n";
            next;
          }

          print "Indexing $file\n" if $debugFile || !$quiet;
          $fileId2Name{$file_id} = $file;

          open FILE, $file or die "Cannot open file: $file!\n";

          # Index the filename itself, excluding the extension:
          my $basename = $file;
          $basename =~ s/\.[^.]+$//;
          indexString($file, $file_id, \%seen_in_file, $basename);

          # Index the file contents:
          while ( <FILE> ) {
            indexString($file, $file_id, \%seen_in_file, $_);
          }
          close FILE;
      }
      @words = sort(keys(%word2FileIds));
      calc_rank();
      print scalar(@inputFiles), " files indexed. ", scalar(@words), " words indexed.\n";
      if (@words > 0) {
        my $maxUsed = @{$word2FileIds{$wordsRanked[0]}};
        my $percentage = 100.0 * $maxUsed / @inputFiles;
        if ($percentage >= 50) {
          printf "Some words were used in %d different files (%4.1f%% of total).\n", $maxUsed, $percentage;
        }
      }
  }

  sub calc_rank {
    @wordsRanked = sort
    {
      my $cmp = scalar(@{$word2FileIds{$a}}) <=> scalar(@{$word2FileIds{$b}});
      return -$cmp if $cmp != 0;
      return $a cmp $b;
    } @words;
  }

  return $self;
} # end of new method.


}
