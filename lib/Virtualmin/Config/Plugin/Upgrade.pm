package Virtualmin::Config::Plugin::Upgrade;
use strict;
use warnings;
no warnings qw(once);
use parent 'Virtualmin::Config::Plugin';

our $config_directory;
our (%gconfig, %miniserv);

sub new {
  my $class = shift;
  # inherit from Plugin
  my $self = $class->SUPER::new(name => 'Upgrade');

  return $self;
}

# actions method performs whatever configuration is needed for this
# plugin. XXX Needs to make a backup so changes can be reverted.
sub actions {
  my $self = shift;

  use Cwd;
  my $cwd = getcwd();
  my $root = $self->root();
  chdir($root);
  $0 = "$root/init-system.pl";
  push(@INC, $root);
  eval 'use WebminCore'; ## no critic
  init_config();

  $self->spin();
  my %wacl = ( 'disallow' => 'upgrade' );
  save_module_acl(\%wacl, 'root', 'webmin');
  my %uacl = ( 'upgrade' => 0 );
  save_module_acl(\%uacl, 'root', 'usermin');
  $self->done(1); # OK!
}

1;