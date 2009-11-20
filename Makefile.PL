use inc::Module::Install;

name 'Template-Plugin-WebGUI-Asset';
all_from 'lib/Template/Plugin/WebGUI/Asset.pm';
readme_from 'lib/Template/Plugin/WebGUI/Asset.pm';
requires 'WebGUI';
requires 'Template';
requires 'PadWalker';
requires 'Scalar::Util';
build_requires 'Test::More';
build_requires 'Test::MockObject';
auto_include_deps;
auto_install;
WriteAll;
