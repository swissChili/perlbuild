# perlbuild

A general purpose build tool in Perl.

Example:

```perl
# build.pl
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
```

## Documentation

Documentation can be generated with the `pod2*` programs. For example,
to generate manpage documentation, the following command would be used:

```sh
$ pod2man perlbuild.pm
```

The output is printed to stdout and can be piped into a file to be used
later.
