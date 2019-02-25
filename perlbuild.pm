package Builder;


=pod 

=head1 TITLE

perlbuild

=head1 DESCRIPTION

A generic build tool written in perl

=head2 EXAMPLE

This is an example of a simple build configuration:

    require './perlbuild.pm';

    my $static =
        Builder
            ->new("gcc")
            ->from("static.c")
            ->static("static");

    Builder
        ->new("gcc")
        ->from("main.c")
        ->from($static)
        ->build("main");

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
    my @times = map { edited_at $_ } @sources;
    my @sorted = sort { $a <=> $b } @times;
    return 1 if ($t_time > @sorted[-1]);
    0;
}

# Class Methods

=pod

=over

=item Builder->new(source)

This function creates a new instance of the GCC Builder class.
The returned instance has several methods useful for compiling
generic programs. Source is used as an initial source file

=back

=cut

sub new{
    my ($class, $c) = @_;
    my $self = bless {
        sources => '',
        links => '',
        compiler => "$c"
    }, $class;
}

=pod

=over

=item builder->link(library)

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

=pod

=over

=item builder->from(source)

Add a source to the builder. Can be either a source file or a
static library. Can receive the return from the builder->static
method as an argument to use that generated library.

=back

=cut

sub from{
    my ($self, $lib) = @_;
    $self->{sources} = $self->{sources} . " $lib";
    return $self;
}

=pod

=over

=item builder->static(target)

Compile the sources to a static library to be linked either with
builder->from or manually. Returns the relative path to the lib
including the build dir so it can be passed directly to another
builder as a source.

=back

=cut
sub static{
    my ($self, $target) = @_;
    system "mkdir -p .build";
    my $cc = $self->{compiler};

    if(target_younger(".build/lib$target.a", $self->{sources})) {
        debug_info "Target built more recently than sources were updated.";
    } else {
        if (target_younger(".build/$target.o", $self->{sources})) {
            debug_info "Target object built more recently than sources were updated";
        } else {
            my $cmd = "$cc -c -o .build/$target.o $self->{sources} $self->{links}";
            debug_cmd $cmd;
            system $cmd;
        }

        $cmd = "ar rcs .build/lib${target}.a .build/$target.o";
        debug_cmd $cmd;
        system $cmd;
    }
    return ".build/lib${target}.a";
}

=pod

=over

=item builder->build(target)

Compiles the sources to a binary target. Links static and dynamic
libraries. Returns the path to the generated binary

=back

=cut
sub build{
    my ($self, $target) = @_;
    system "mkdir -p .build";
    my $cc = $self->{compiler};
    my $younger = target_younger(".build/$target", $self->{sources});
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