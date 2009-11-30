use Test::MockObject;
use Test::More tests => 1;
use Template;

my $snippet = Test::MockObject->new;
my ($prep, $togg);
$snippet->mock( prepareView => sub { $prep = 1 } )
    ->mock( toggleToolbar   => sub { $togg = 1 } )
    ->mock( view            => sub { $prep && $togg && '$variable' } );

my $template = <<'END_TT';
[% FILTER collapse %]
    [% USE snip = WebGUI::Asset(asset => asset) %]
    [% snip.include(variable='foo') %]
    [% snip.include({variable => 'bar'}) %]
    [% snip.include(variable => 'baz') %]
[% END %]
END_TT

my $tt = Template->new(
    INTERPOLATE => 1,
    POST_CHOMP  => 1,
    EVAL_PERL   => 0,
);

$tt->process(\$template, { asset => $snippet }, \my $output);

is($output, 'foo bar baz', 'sending variables works')
    || diag $tt->error;
