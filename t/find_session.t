use warnings;
use strict;

use Test::More tests => 1;
use Template::Plugin::WebGUI::Asset;

package WebGUI::Session;
no warnings 'redefine';

our $singleton = bless {}, __PACKAGE__;

sub new { $singleton }

package WebGUI::Asset;
no warnings 'redefine';

sub newByUrl {
    my ($class, $session) = @_;
    bless { session => $session }, $class;
}

sub view {
    return shift->{session};
}

package main;

sub deeper_still {
    Template::Plugin::WebGUI::Asset->new(undef, url => 'not really');
}

sub deeper {
    deeper_still;
}

sub toplevel {
    my $session = WebGUI::Session->new;
    deeper()->{raw};
}

is(toplevel, $WebGUI::Session::singleton, 'got the singleton back.');
