#!/usr/bin/perl

# extract multiple ipv4 address and perform dns lookup from a chunk of text
# export into a CSV
# perl connections.pl > connections.csv
# then open with open office or similar csv viwer


use strict;
use warnings;

# you need Socket.pm to do this, to install when not behind a proxy:
# perl –MCPAN –e shell
# cpan> install Socket
# exit

use Socket;

my %ips;

#process line by line:
while(<DATA>) {
    # each time we find an IP
    # this regex is designed to be all on one line.
    while (/(?!0+\.0+\.0+\.0+$)(([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5]))/g) {

        # put whatever we just matched into a more permanent variable
        my $ip = $1;

        # put in a hash to remove duplicates
        $ips{$ip} = $ip;
    }
}

# loop over the unique IP addrs
foreach my $key (sort keys %ips) {
    print $key;

    # pretending that I don't want to see 192 or 10 net stuff
#    unless (($key =~ m/^192/) or ($key =~ m/^10\./)) {

        # array of 4 octets
        my @numbers = split (/\./, $key);

        # packed into the format gethostbyaddr likes
        my $ipPacked = pack("C4", @numbers);

        # the FQDN, or 'unknown'
        my $name = gethostbyaddr( $ipPacked, 2 ) || 'unknown';
        print ",$name";

        # end of the "unless" swich
#    } else { 
#        print ",unknown"
#    }

    # newline
    print "\n";
}

__DATA__
192.168.0.101
192.168.0.102
192.168.0.103
192.168.0.104
192.168.0.105
192.168.0.106
192.168.0.107
192.168.0.108