#!/usr/bin/env perl
use warnings;
use strict;
use Math::BigInt;
use Math::BigFloat;
use LWP;
use JSON::XS;
use Path::Tiny;
use Data::Dumper;
use Modern::Perl;
use Math::Trig;
die "Usage: $0 URL-Townland-file.txt" unless @ARGV;

my $PI = atan2( 1, 1 ) * 4;
my $browser = LWP::UserAgent->new;
path("wkt-output")->mkpath;

while (<>) {
    chomp;

    #ignore comments and blank lines
    next if ( /^\s*$/ || /#/ );

    my ( $url, $townland ) = split(/\|/);
    say "Using:", "$url for $townland";

    #Get the townland page
    my $response = $browser->get( 'http://www.townlands.ie' . $url );
    die "Can't get $url -- ", $response->status_line
        unless $response->is_success;
    my $townland_html = $response->content;

    #Scrape
    my ($geojson) = $townland_html =~ /.*L.geoJson\((.*)\)\.addTo\(map\)/gsmx;
    $geojson =~ s/\'/"/g;    # Make double-quotes for strict parser
    say "Got GeoJSON for $townland";

    my $json_text = decode_json $geojson;
    my $path      = path("./wkt-output/$townland.wkt");

    unfold( $json_text, $path );
}

sub unfold {
    my ( $js, $path ) = @_;
    $path->spew_utf8( 'GEOMETRYCOLLECTION (',$js->{geometry}->{type}, "((\n" );
    for my $coord_set ( @{ $js->{geometry}->{coordinates} } ) {
        for my $point (@$coord_set) {
            $path->append_utf8( join( " ", @$point ), ",\n" );
        }
    }


    sub degrees_to_meters {
        my ( $lon, $lat ) = @_;
        my $x = ($lon * 20037508.34) / 180;
        my $y = log(tan((90 + $lat) * $PI / 360)) / ($PI / 180);
        $y = $y * 20037508.34 / 180;
        return ("$x $y,")
    }
    
    # Callbacks for edit_utf8
    my $demercator_ize
        = sub { s/(-?\d+\.\d+)\s(-?\d+\.\d+)\,/&degrees_to_meters($1,$2)/ge; };

    my $chomp_last_comma = sub { chop; chop };

    #In place edits
    $path->edit_utf8($demercator_ize);

    $path->edit_utf8($chomp_last_comma);
    $path->append_utf8(')))');

    say "$js->{properties}->{name} written to $path", "\n", '-' x 10, "\n";
}

