# Get Irish townland data for the Neatline geotemporal exhibits builder from townlands.ie

Converts to WKT, changing the projection from WGS84 Web Mercator aka EPSG:900913,
(as used by OpenStreepMap & Google maps etc), to WGS 84 aka EPSG:4326 as used by GPS satellite navigation systems and Neatline, from Scholar Labs.

##Contents:

- sample_urls.txt: sample file of pipe-delimited townlands.ie relative-urls and townland names

- geoj-wkt.pl: script to get the townland geojson encoded coordinates and do conversion. Creates a directory 'wkt-output' with a seperate file for each townland processed.

- README.md: this file
