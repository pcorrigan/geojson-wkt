# Get Irish townland data for the Neatline Geotemporal Exhibits builder from www.townlands.ie

This utility converts from the GeoJSON found on www.townlands.ie to EPSG:3857 encoded as [WKT] (https://en.wikipedia.org/wiki/Well-known_text) and suitable for import to Neatline

##Contents:

- sample_urls.txt: sample file of pipe-delimited townlands.ie relative-urls and townland names

- geoj-wkt.pl: script to get the townland geojson encoded coordinates and do conversion. Creates a directory 'wkt-output' with a seperate file for each townland processed.

- README.md: this file
