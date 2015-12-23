package TownCrier;

use Dancer;
use Dancer::Plugin::Auth::Basic;
use CHI;

use TownCrier::Model;
use TownCrier::Handler::Site;
use TownCrier::Handler::Admin;
use TownCrier::Handler::Feed;
use TownCrier::Handler::API;

use List::Util qw(min);

use constant TOWNCRIER_DATABASE =>
    $ENV{TOWNCRIER_DATABASE} // config->{towncrier}->{database} // "towncrier.sqlite";

use constant TOWNCRIER_ADMIN_USER =>
    $ENV{TOWNCRIER_ADMIN_USER} // config->{towncrier}->{admin_user} // "admin";
use constant TOWNCRIER_ADMIN_PASSWORD =>
    $ENV{TOWNCRIER_ADMIN_PASSWORD} // config->{towncrier}->{admin_password} // "secret";

hook before => sub {
    my $db = TownCrier::Model->new(dsn => "dbi:SQLite:dbname=".TOWNCRIER_DATABASE);
    var db => $db;
    var dbscope => $db->new_scope;
};

hook before => sub {
    return unless request->path_info =~ m{^/admin/};
    auth_basic
        realm    => 'api',
        user     => TOWNCRIER_ADMIN_USER,
        password => TOWNCRIER_ADMIN_PASSWORD;
};

my $cache = CHI->new(driver => 'FastMmap', cache_size => '10m');

sub cached (&) {
    my ($s) = @_;
    return sub {
        content_type 'text/html';
        my $expiry_key = "_expiry_".request->uri;
        my $expires_in = $cache->get($expiry_key) // 1;
        my $out = $cache->compute(request->uri, $expires_in, sub {
            $cache->set($expiry_key, min($expires_in * 1.6, 3600));
            [$s->(), content_type()];
        });
        content_type $out->[1];
        $out->[0];
    };
}

sub cache_cleared (&) {
    my ($s) = @_;
    return sub { $cache->clear; $s->() };
}

get "/"                          => cached \&TownCrier::Handler::Site::index;
get "/services/:service/?:date?" => cached \&TownCrier::Handler::Site::service;
get "/groups/:group"             => cached \&TownCrier::Handler::Site::index;
get "/notices"                   => cached \&TownCrier::Handler::Site::notices;

prefix "/admin";

get  "/event" => cached \&TownCrier::Handler::Admin::Event::form;
post "/event" => cache_cleared \&TownCrier::Handler::Admin::Event::submit;

prefix "/feed";

get "/"                  => cached \&TownCrier::Handler::Feed::index;
get "/services/:service" => cached \&TownCrier::Handler::Feed::service;

prefix "/admin/api/v1";

get  "/services"          => cached \&TownCrier::Handler::API::Service::list;
post "/services"          => cache_cleared \&TownCrier::Handler::API::Service::post;
get  "/services/:service" => cached \&TownCrier::Handler::API::Service::get;
del  "/services/:service" => cache_cleared \&TownCrier::Handler::API::Service::delete;

get  "/statuses"         => cached \&TownCrier::Handler::API::Status::list;
post "/statuses"         => cache_cleared \&TownCrier::Handler::API::Status::post;
get  "/statuses/:status" => cached \&TownCrier::Handler::API::Status::get;
del  "/statuses/:status" => cache_cleared \&TownCrier::Handler::API::Status::delete;

get  "/groups"                 => cached \&TownCrier::Handler::API::Group::list;
post "/groups"                 => cache_cleared \&TownCrier::Handler::API::Group::post;
get  "/groups/:group"          => cached \&TownCrier::Handler::API::Group::get;
del  "/groups/:group"          => cache_cleared \&TownCrier::Handler::API::Group::delete;
get  "/groups/:group/services" => cached \&TownCrier::Handler::API::Group::list_services;

get  "/services/:service/events"        => cached \&TownCrier::Handler::API::Event::list;
post "/services/:service/events"        => cache_cleared \&TownCrier::Handler::API::Event::post;
get  "/services/:service/events/:event" => cached \&TownCrier::Handler::API::Event::get;
del  "/services/:service/events/:event" => cache_cleared \&TownCrier::Handler::API::Event::delete;

get  "/notices"         => cached \&TownCrier::Handler::API::Notice::list;
post "/notices"         => cache_cleared \&TownCrier::Handler::API::Notice::post;
get  "/notices/:notice" => cached \&TownCrier::Handler::API::Notice::get;
del  "/notices/:notice" => cache_cleared \&TownCrier::Handler::API::Notice::delete;

prefix "/api/v1";

get  "/services"                        => cached \&TownCrier::Handler::API::Service::list;
get  "/services/:service"               => cached \&TownCrier::Handler::API::Service::get;
get  "/statuses"                        => cached \&TownCrier::Handler::API::Status::list;
get  "/statuses/:status"                => cached \&TownCrier::Handler::API::Status::get;
get  "/groups"                          => cached \&TownCrier::Handler::API::Group::list;
get  "/groups/:group"                   => cached \&TownCrier::Handler::API::Group::get;
get  "/services/:service/events"        => cached \&TownCrier::Handler::API::Event::list;
get  "/services/:service/events/:event" => cached \&TownCrier::Handler::API::Event::get;
get  "/notices"                         => cached \&TownCrier::Handler::API::Notice::list;
get  "/notices/:notice"                 => cached \&TownCrier::Handler::API::Notice::get;

1;
