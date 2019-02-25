#!/usr/bin/env perl
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
