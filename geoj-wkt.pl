#!/usr/bin/env perl
use warnings;
use strict;

# Dependencies
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

while  (<>) {
    chomp;
    
    #ignore comments and blank lines
    next if (  /^\s*$/||/#/) ; 
    
    my ( $url, $townland ) = split(/\|/);
    say "Using:", "$url for $townland";
    my $response = $browser->get( 'http://www.townlands.ie' . $url );
    die "Can't get $url -- ", $response->status_line
        unless $response->is_success;
    my $townland_html = $response->content;
    
    #Scrape
    my ($geojson) = $townland_html =~ /.*L.geoJson\((.*)\)\.addTo\(map\)/gsmx;
    $geojson =~ s/\'/"/g;    # Make double-quotes for strict parser
    say "Got GeoJSON for $townland";
    
    my $path      = path("./wkt-output/$townland.wkt");
    my $json_text = decode_json $geojson;
    unfold( $json_text, $path );
}


sub  unfold {
    my ( $js, $path ) = @_;
    $path->spew_utf8( $js->{geometry}->{type}, "((\n" );
    for my $coord_set ( @{ $js->{geometry}->{coordinates} } ) {
        for my $point (@$coord_set) {
            $path->append_utf8( join( " ", @$point ), ",\n" );
        }
    }

#-9.8815003 53.2977326, -9.8812643 53.2981558, -9.8808029 53.298284, -9.8802772 53.298502, -9.8798803 53.2984892, -9.8796764 53.2982904, -9.8796335 53.2981173, -9.8796442 53.2979826

    sub  to_merc {
        my ( $lat, $lon ) = @_;

        #say "lat is $lat and lon is $lon";
        my $x = $lon * 20037508.34 / 180;
        my $y = log( tan( ( 90 + $lat ) * $PI / 360 ) ) / ( $PI / 180 );
        $y = $y * 20037508.34 / 180;
        $x = sprintf( "%.2f", ($x) );
        $y = sprintf( "%.2f", ($y) );
        return "$x $y,";
    }

    # Callbacks for edit_utf8
    my $de_mercator_ize
        = sub { s/(-?\d+\.\d+)\s(-?\d+\.\d+)\,/&to_merc($1,$2)/ge; };
    my $chomp_last_comma = sub { chop; chop };

    $path->edit_utf8($de_mercator_ize);
    $path->edit_utf8($chomp_last_comma);
    $path->append_utf8('))');

    say "$js->{properties}->{name} written to $path", "\n", '-' x 10, "\n";
}

