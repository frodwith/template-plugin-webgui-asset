package Template::Plugin::WebGUI::Asset;

require v5.8.8;

our $VERSION = '0.01';

use warnings;
use strict;

use WebGUI::Asset;
use PadWalker qw(peek_my);
use Scalar::Util qw(blessed);

use base 'Template::Plugin';

=head1 NAME

Template::Plugin::WebGUI::Asset

=head1 DESCRIPTION

A plugin for including/processing/inserting the output of a WebGUI asset's
view method.

=head1 SYNOPSIS

    [% USE my_asset = WebGUI::Asset(asset => an_asset_reference) %]

    [%# or... %]

    [% USE WebGUI::Asset(
           name    => 'my_asset', 
           session => a_session_reference,
           url     => 'an_asset_url', # or id => 'an_asset_id'
       ) %]
    
    [%# or, in mid webgui request, omit session %]

    [% USE my_asset = WebGUI::Asset(url => 'an_asset_url') %]

    [%# Then... %]

    [% my_asset.include # just like INCLUDE afilename %]
    [% my_asset.process # just like PROCESS afilename %] 
    [% my_asset.insert  # just like INSERT  afilename %]

=head1 FAIR WARNING

The typical use case for this module is being called by WebGUI's template
engine, which doesn't give us any help in the form of an asset or session
reference.  We therefore have to walk the stack and find the session it's
calling us with.  That's a nasty hack, so be warned.  It can be solved in the
future if need be by writing a new template processor (or modifying the old
one) that passes us a session reference.

=head1 METHODS

=cut

# I sat rocking in the dank, dirty corner of the room that I had claimed for
# myself.  The unspeakable things which I had enacted upon my callers kept
# running through my mind, laughing at me, LAUGHING AT ME, the horrors twin
# rivulets of blood run down the cheeks from my ruined eyes I had perpetrated
# on people who OH MY GOD HE WHO WAITS BEHIND trusted me to be a well behaved
# module THE WALL OH GOD HE COMES ZALGO HE COMES.

# On a sadder note, yes, we're really going to walk up the stack looking for
# WebGUI sessions.

sub find_session {
    for (my $i = 2; my $locals = eval { peek_my($i) }; $i++) {
        foreach my $varname (keys %$locals) {
            my $ref   = $locals->{$varname};
            next unless ref $ref eq 'REF';

            my $value = $$ref;
            return $value if blessed($value) && $value->isa('WebGUI::Session');
        }
    }
}

sub kwargs {
    my $a = shift;
    return ref $a->[0] eq 'HASH' ? $a->[0] : { @$a };
}

=head2 new (context, params)

When you call this plugin, pass it either an asset param (asset => $asset) or
a session and a id or url (session => $session, id => $assetId) or (session =>
$session, url => $url).  If it has to, it will walk up the call stack looking
for a session to use.  That's probably what will end up happening until the
WebGUI template api changes, but if you can avoid it, you should.

You can also pass a name to bind the variable to (e.g. 
[% USE ... name => foo %] [% foo.process %]), or do [% USE foo = ... %], it's
a matter of style.

=cut

sub new {
    my $class   = shift;
    my $context = shift;
    my $params  = kwargs(\@_);
    my $self    = bless { context => $context }, $class;

    my $asset = $params->{asset};
    unless ($asset) {
        my $session = $params->{session} || find_session
            or die 'Could not find a WebGUI session';

        if (my $id = $params->{assetId}) {
            $asset = WebGUI::Asset->new($session, $id)
                or die "No asset found with id $id";
        }
        elsif (my $url = $params->{url}) {
            $asset = WebGUI::Asset->newByUrl($session, $url)
                or die "No asset found with url $url";
        }
    }

    die 'No way to get an asset' unless $asset;

    $asset->toggleToolbar;
    $asset->prepareView;
    $self->{raw} = $asset->view;

    if (my $name = $params->{name}) {
        $context->stash->set($name => $self);
    }

    return $self;
}

=head2 process

Processes the output of the assets's view() method in the current template
context.  See the PROCESS directive in TT.  You can optionally provide named
arguments (as a hash or in the key=value syntax) just like you can with the
PROCESS directive.

=cut

sub process {
    my $self = shift;
    my $vars = kwargs(\@_);

    return $self->{context}->process(\$self->{raw}, $vars);
}

=head2 include

Includes the output of the asset's view() method in a new template context.
See the INCLUDE directive in TT.  You can optionally provide named
arguments (as a hash or in the key=value syntax) just like you can with the
INCLUDE directive.


=cut

sub include {
    my $self = shift;
    my $vars = kwargs(\@_);

    return $self->{context}->include(\$self->{raw}, $vars);
}

=head2 insert

Outputs the contents of the asset's view() method without processing it at
all.  See the INSERT directive in TT.

=cut

sub insert {
    return shift->{raw};
}

=head1 AUTHOR

Paul Driver, C<< <frodwith at cpan.org> >>

=head1 LICENSE

This module is licensed under the same terms as Perl itself.

=cut

1;
