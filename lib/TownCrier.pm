package TownCrier;

use Dancer;
use Dancer::Plugin::Auth::Basic;

use TownCrier::Model;
use TownCrier::Handler::Site;
use TownCrier::Handler::Feed;
use TownCrier::Handler::API;

my $db = TownCrier::Model->new( dsn => "dbi:SQLite:dbname=".(config->{towncrier}->{database} // "towncrier.sqlite") );

hook before => sub {
    var db => $db;
    var dbscope => $db->new_scope;
};

get "/"                          => \&TownCrier::Handler::Site::index;
get "/services/:service/?:date?" => \&TownCrier::Handler::Site::service;
get "/groups/:group"             => \&TownCrier::Handler::Site::index;

prefix "/feed";

get "/"                  => \&TownCrier::Handler::Feed::index;
get "/services/:service" => \&TownCrier::Handler::Feed::service;

prefix "/admin/api/v1";

get  "/services"          => \&TownCrier::Handler::API::Service::list;
post "/services"          => \&TownCrier::Handler::API::Service::post;
get  "/services/:service" => \&TownCrier::Handler::API::Service::get;
del  "/services/:service" => \&TownCrier::Handler::API::Service::delete;

get  "/statuses"         => \&TownCrier::Handler::API::Status::list;
post "/statuses"         => \&TownCrier::Handler::API::Status::post;
get  "/statuses/:status" => \&TownCrier::Handler::API::Status::get;
del  "/statuses/:status" => \&TownCrier::Handler::API::Status::delete;

get  "/groups"                 => \&TownCrier::Handler::API::Group::list;
post "/groups"                 => \&TownCrier::Handler::API::Group::post;
get  "/groups/:group"          => \&TownCrier::Handler::API::Group::get;
del  "/groups/:group"          => \&TownCrier::Handler::API::Group::delete;
get  "/groups/:group/services" => \&TownCrier::Handler::API::Group::list_services;

get  "/services/:service/events"        => \&TownCrier::Handler::API::Event::list;
post "/services/:service/events"        => \&TownCrier::Handler::API::Event::post;
get  "/services/:service/events/:event" => \&TownCrier::Handler::API::Event::get;
del  "/services/:service/events/:event" => \&TownCrier::Handler::API::Event::delete;

get  "/notices"         => \&TownCrier::Handler::API::Notice::list;
post "/notices"         => \&TownCrier::Handler::API::Notice::post;
get  "/notices/:notice" => \&TownCrier::Handler::API::Notice::get;
del  "/notices/:notice" => \&TownCrier::Handler::API::Notice::delete;

prefix "/api/v1";

get  "/services"                        => \&TownCrier::Handler::API::Service::list;
get  "/services/:service"               => \&TownCrier::Handler::API::Service::get;
get  "/statuses"                        => \&TownCrier::Handler::API::Status::list;
get  "/statuses/:status"                => \&TownCrier::Handler::API::Status::get;
get  "/groups"                          => \&TownCrier::Handler::API::Group::list;
get  "/groups/:group"                   => \&TownCrier::Handler::API::Group::get;
get  "/services/:service/events"        => \&TownCrier::Handler::API::Event::list;
get  "/services/:service/events/:event" => \&TownCrier::Handler::API::Event::get;
get  "/notices"                         => \&TownCrier::Handler::API::Notice::list;
get  "/notices/:notice"                 => \&TownCrier::Handler::API::Notice::get;

1;
