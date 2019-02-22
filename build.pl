#!/usr/bin/env perl
require './perlbuild.pm';

my $static =
    Gcc ->new("static.c")
        ->static("static");

Gcc ->new("main.c")
    ->from($static)
    ->build("main");
