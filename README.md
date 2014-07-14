# ![](https://raw.githubusercontent.com/robn/towncrier/master/public/images/bell/bell-48.png) towncrier

A simple status dashboard.

## features

- Standalone - just Perl and some modules, no web server or database required
- REST API - including a public read-only one
- RSS feeds

## setup

I'm assuming you have Perl. You'll need the following packages installed as well

- Dancer
- Dancer::Plugin::Auth::Basic
- Dancer::Plugin::Feed
- Moo
- Types::Standard
- Type::Utils
- KiokuDB
- KiokuDB::Backend::DBI
- KiokuX::Model
- DBD::SQLite
- Search::GIN
- DateTime
- DateTime::Format::Human::Duration
- DateTime::Format::ISO8601
- DateTime::Format::DateParse
- Template
- Text::Slugify

That's enough to get running, though for production you'll probably want a
better web server than Dancer's development server. I like Starman. Read
Dancer::Deployment for more options.

Start it up:

  $ ./bin/app.pl

You need to install the initial statuses and services. Look at bin/fixtures.sh
to get started.

There's some knobs you can twiddle in config.yml.

## demo

FastMail are using this. See http://fastmailstatus.com/

## credits and license

Copyright (c) 2014 Robert Norris. MIT license. See LICENSE.

towncrier started as a clone of Stashboard. The templates, stylesheets and
general layout are lifted from it. So Copyright (c) 2010 Twilio Inc.

Uses Font Awesome by Dave Gandy. http://fontawesome.io

Bell icon by icons8.com

I think that's everyone.

## contributing

Please hack on this and send pull requests :)

