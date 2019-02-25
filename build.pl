#!/usr/bin/env perl
require './perlbuild.pm';

my $gcc = Builder->new('gcc');

my $static =
    $gcc->from("static.c")
        ->static("static");

$gcc->from("main.c")
    ->from($static)
    ->indirect("header.h")
    ->build("main");
