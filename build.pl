#!/usr/bin/env perl
require './perlbuild.pm';

my $gcc = Builder->new('gcc');
my $run = Runner->new();

$run->task('main', sub{
    my $static = $run->call('static');

    $gcc->from("main.c")
        ->from($static)
        ->indirect("header.h")
        ->build("main");
});

$run->task('static', sub{
    $gcc->from("static.c")->static("static");
});

$run->run();
