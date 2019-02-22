# perlbuild

A general purpose build tool in Perl.

Example:

```perl
#!/usr/bin/env perl
# build.pl

require './perlbuild.pm';

my $static =
    Gcc ->new("static.c")
        ->static("static");

Gcc ->new("main.c")
    ->from($static)
    ->build("main");
```
