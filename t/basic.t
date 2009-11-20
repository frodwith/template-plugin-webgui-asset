use Test::MockObject;
use Test::More tests => 1;
use Template;

my $snippet = Test::MockObject->new;
$snippet->mock(
    view => sub {
        return  '[% 2 + 2 %]';
    }
);

my $template = <<'END_TT';
[% FILTER collapse %]
    [% USE WebGUI::Asset name => 'test', asset => asset %]
    [% test.process %]
    [% test.include %]
    [% test.insert %]
[% END %]
END_TT

my $tt = Template->new(
    INTERPOLATE => 1,
    POST_CHOMP  => 1,
    EVAL_PERL   => 0,
);

$tt->process(\$template, { asset => $snippet }, \my $output);

is($output, '4 4 [% 2 + 2 %]', 'basic usage works')
    || diag $tt->error;
