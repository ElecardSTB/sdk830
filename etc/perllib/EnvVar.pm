# See end of file for documenation in POD format.

package EnvVar;

use Msg; BEGIN { debugLevel(0); }

sub EnvVar::envVarExpand {
    my ($str, $location) = @_;
    my $origStr = $str;
    my $splitRx = '(\$\w+|[^\$]+)';
    # split into bits with/without variable refs:
    my @stack = $str =~ /$splitRx/go;
    my @result;
    if (debugLevel >= 3) {
        debugx(3, "$location: \"$str\" expanding...");
        map {debugx(3, "$_ ...")} @stack;
    }
    while (@stack) {
        my $x = shift @stack;
        if ($x =~ /^\$(\w+)$/) {
            my $varRef = $1;
            my $val = $ENV{$varRef};
            if (defined $val) {
                debugx(4, "$location: Expanding $& in $str to $val");
                unshift @stack, ($val =~ /$splitRx/go);
                next;
            } else {
                warn("$location: Undefined env var referenced: \"$varRef\"") if debugEnabled(1);
            }
        }
        push @result, $x;
    }
    $str = join "", @result;
    if ($origStr ne $str) {
        debugx(3, "$location: \"$origStr\" expanded to \"$str\"");
    }
    $str;
}

1;
__END__

=head1 EnvVar

Usage: use EnvVar;

Environment variable utilities.

=head2 envVarExpand

Usage: C<envVarExpand($str, $location)>

Expands environment variable references in the form $XXX and %XXX%.
$location is used in any messages.
