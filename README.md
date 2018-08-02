# ![](https://raw.githubusercontent.com/robn/towncrier/master/public/images/bell/bell-48.png) towncrier

A simple status dashboard.

## features

- Standalone - just Perl and some modules, no web server or database required
- REST API - including a public read-only one
- RSS feeds

## setup

### docker

Docker is the easiest way to get things running:

```bash
$ docker run --name=towncrier -d -p 8080:8080 robn/towncrier
```
### Existing Perl with Carton

If you have a system with a fairly recent Perl already, then Carton is your
next best choice:

```bash
$ git clone http://github.com/robn/towncrier.git
$ cd towncrier
$ curl -L http://cpanmin.us | perl - Carton
$ carton install --deployment
$ carton exec plackup bin/app.pl
```
For production you'll need to know a little more about Perl webapp deployment.
Go and read the docs for Carton and Dancer::Deployment.

### anything else

Get Perl, get all the dependencies, run the program. This is the developer
option, and you're expected to know what you're doing :)

Expect to install the development packages for `libxml2` and `expat` for your
distribution as well as `make` and `gcc`.

### first run

You need to install the initial statuses and services. Look at bin/fixtures.sh
to get started.

There's some knobs you can twiddle in config.yml.

## demo

FastMail are using this. See http://www.fastmailstatus.com/

## credits and license

Copyright (c) 2014 Robert Norris. MIT license. See LICENSE.

towncrier started as a clone of Stashboard. The templates, stylesheets and
general layout are lifted from it. So Copyright (c) 2010 Twilio Inc.

Uses Font Awesome by Dave Gandy. http://fontawesome.io

Uses Pure CSS by Yahoo!. http://purecss.io

Bell icon by icons8.com

I think that's everyone.

## contributing

Please hack on this and send pull requests :)

