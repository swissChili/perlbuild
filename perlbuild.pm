package Gcc;


=pod 

=head1 TITLE

perlbuild

=head1 DESCRIPTION

A generic build tool written in perl

=head2 USAGE

=cut



use File::stat;
use FileHandle;


my $yellow = "\033[33m";
my $reset  = "\033[0m";
my $cyan   = "\033[36m";
my $code   = "\033[3m";

sub debug_info{
    my $info = shift;
    print "${yellow}[ INFO ]$reset $info\n";
}

sub debug_cmd{
    my $cmd = shift;
    print "${cyan}[ CMD ]$reset${code} $cmd $reset\n";
}

sub edited_at{
    my $file = shift;
    if (-e $file) {
        my $fh = FileHandle->new($file);
        return (stat($fh))[0][9];
    } else {
        print "existsn't $file\n";
        return 0;
    }
}

sub target_younger{
    my ($target, $others) = @_;
    my $t_time = edited_at $target;
    my @sources = split ' ', $others;
    print "sources: $others\nSplit: @sources\n";
    my @times = map { edited_at $_ } @sources;
    my @sorted = sort { $a <=> $b } @times;
    print "target: $t_time\nYoungest: @sorted[-1]\n\@sources @sources[0]\n";
    return 1 if ($t_time > @sorted[-1]);
    0;
}

# Class Methods

=pod

=over

=item gfc->new(source)

This function creates a new instance of the GCC Builder class.
The returned instance has several methods useful for compiling
generic programs. Source is used as an initial source file

=back

=cut

sub new{
    my ($class, $files) = @_;
    my $self = bless {
        sources => $files,
        links => "",
        compiler => 'gcc'
    }, $class;
}

=pod

=over

=item gfc->link(library)

Adds a dynamic library to the list of libs to link. This,
like all methods in perlbuild does not actually build when
it is called, but rather set up parameters for a build method
to use later. See "static" or "build" for more info.

=back

=cut

sub link{
    my ($self, $lib) = @_;
    my @split = split ' ', $lib;
    my $links = join ' -l ', @split;
    $self->{links} = "-l " . $links;
    return $self;
}

sub from{
    my ($self, $lib) = @_;
    $self->{sources} = $self->{sources} . " $lib";
    return $self;
}

# Builds a static lib from an object
sub static{
    my ($self, $target) = @_;
    my $cc = $self->{compiler};
    my $younger = target_younger($target, $self->{sources});
    if($younger) {
        debug_info "Target built more recently than sources were updated.";
    } else {
        my $cmd = "$cc -c -o .build/$target.o $self->{sources} $self->{links}";
        debug_cmd $cmd;
        system $cmd;

        $cmd = "ar rcs .build/lib${target}.a .build/$target.o";
        debug_cmd $cmd;
        system $cmd;
    }
    return ".build/lib${target}.a";
}

sub build{
    my ($self, $target) = @_;
    my $cc = $self->{compiler};
    my $younger = target_younger($target, $self->{sources});
    if($younger) {
        debug_info "Target built more recently than sources were updated.";
    } else {
        my $cmd = "$cc -o .build/$target $self->{sources} $self->{links}";
        debug_cmd $cmd;
        system($cmd);
    }
    return $target;
}

1;