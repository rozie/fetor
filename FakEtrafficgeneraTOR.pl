#!/usr/bin/perl

use strict;
use warnings;
use WWW::Mechanize;
use autodie;

my $debug        = 1;                         # verbose mode AKA debug
my $configfile   = "$ENV{HOME}/.fetor.rc";    # config file location
my %URL_sites    = ();                        # URLs to scan for sites to visit
my %crawl_URLs   = ();                        # URLs to be crawled
my $processcount = 8;                         # how many crawler processes
my $minsleeptime = 1;     # base sleep time for crawler processes
my $sleeprandom  = 15;    # random factor of sleeptime

# read config file
open( CFG, "$configfile" );
while (<CFG>) {
    chomp;
    if ( !/^\s*#/ ) {
        if (/^(http|https)/) {
            $URL_sites{$_} = 1;
        }
    }
}
close(CFG);

# prepare URLs to be crawled
foreach my $data_site ( keys %URL_sites ) {
    my $mech = WWW::Mechanize->new();
    $mech->get($data_site);
    my @links = $mech->find_all_links(
        tag       => "a",
        url_regex => qr/http/i
    );
    foreach (@links) {
        my ( $url, $name ) = @$_;

        # verify links if they work
        my $mech = WWW::Mechanize->new(
            autocheck => 0,
            timeout   => 5
        );
        $mech->agent_alias('Linux Mozilla');
        $mech->get($url);
        my $status = $mech->success();
        if ($status) {
            $crawl_URLs{$url} = 1;
            print "$url ADDED\n" if $debug;
        }
        else {
            print "$url SKIPPED - not working\n" if $debug;
        }
    }
}

# prepare data for child processes
my @URL_list   = keys %crawl_URLs;
my $item_count = 1 + $#URL_list;

# debug final data
if ($debug) {
    print "All URLs to be crawled:";
    foreach (@URL_list) {
        print "$_\n";
    }
    print "Total URL count $item_count\n";
    print "Starting daemon...\n";
}

# run daemons
for ( my $i = 0 ; $i <= $processcount ; $i++ ) {
    if ( fork() == 0 ) {
        my $size = 0;
        while (1) {
            srand();
            my $linknumber = int( rand($item_count) );
            my $url        = $URL_list[$linknumber];
            my $mech       = WWW::Mechanize->new( autocheck => 0 );
            $mech->agent_alias('Linux Mozilla');
            $mech->get($url);
            $size += length( $mech->content() );
            my $status    = $mech->success();
            my $sleeptime = $minsleeptime + int( rand($sleeprandom) );
            print
"got $url with status $status sleeping for $sleeptime, total bytes count $size\n"
              if $debug;
            sleep $sleeptime;
        }
        exit;
    }
}
