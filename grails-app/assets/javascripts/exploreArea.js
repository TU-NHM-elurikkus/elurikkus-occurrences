// Note there are some global variables that are set by the calling page (which has access to
// the ${pageContet} object, which are required by this file.:

function loadExploreArea(EYA_CONF) {
    var state = {
        speciesGroup: 'ALL_SPECIES'
    };

    var geocoder, map, marker, circle, markerInfowindow, lastInfoWindow, taxon, taxonGuid;
    var points = [];
    var infoWindows = [];
    var zoomForRadius = {
        1000: 14,
        5000: 12,
        10000: 11
    };
    var radiusForZoom = {
        11: 10,
        12: 5,
        14: 1
    };

    // Load Google maps via AJAX API
    if(EYA_CONF !== undefined && !EYA_CONF.hasGoogleKey) {
        google.load('maps', '3.3', { other_params: 'sensor=false' });
    }

    /**
     * Document onLoad event using JQuery
     */
    $(document).ready(function() {
        // initialise Google Geocoder
        geocoder = new google.maps.Geocoder();

        // Catch page events...
        registerEventHandlers();

        // Handle back button and saved URLs
        // hash coding: #lat|lng|zoom
        var hash = window.location.hash.replace(/^#/, '');
        var hash2;
        var defaultParam = $.url().param('default'); // requires JS import: purl.js

        if(hash.indexOf('%7C') !== -1) {
            // already escaped
            hash2 = hash;
        } else {
            // escape used to prevent injection attacks
            hash2 = encodeURIComponent(hash);
        }

        var query = $.url().param('q');

        if(defaultParam) {
            initialize();
        } else if(hash2) {
            var hashParts = hash2.split('%7C'); // note escaped version of |
            if(hashParts.length === 3) {
                bookmarkedSearch(hashParts[0], hashParts[1], hashParts[2], null);
            } else if(hashParts.length === 4) {
                bookmarkedSearch(hashParts[0], hashParts[1], hashParts[2], hashParts[3]);
            } else {
                attemptGeolocation();
            }
        } else if(query) {
            $('#address').val(query);
            geocodeAddress();
        } else {
            attemptGeolocation();
        }

        addTooltips();

    }); // end onLoad event

    // var proj900913 = new OpenLayers.Projection("EPSG:900913");
    // var proj4326 = new OpenLayers.Projection("EPSG:4326");

    // pointer fn
    function initialize() {
        loadMap();
        loadGroups();
    }

    function registerEventHandlers() {
        // Register events for the species_group column
        $('#taxa-level-0 tbody tr').live('mouseover mouseout', function(event) {
            // mouse hover on groups
            if(event.type === 'mouseover') {
                $(this).addClass('hoverRow');
            } else {
                $(this).removeClass('hoverRow');
            }
        }).live('click', function(e) {
            // catch the link on the taxon groups table
            e.preventDefault(); // ignore the href text - used for data
            groupClicked(this);
        });

        // By default action on page load - show the all species group (simulate a click)
        // $('#taxa-level-0 tbody td:first').click();

        // register click event on "Search" button"
        $('#locationSearch').click(
            function(e) {
                e.preventDefault(); // ignore the href text - used for data
                geocodeAddress();
            }
        );

        // Register onChange event on radius drop-down - will re-submit form
        $('select#radius').change(
            function(e) {
                EYA_CONF.radius = parseInt($(this).val());
                var radiusInMetres = EYA_CONF.radius * 1000;
                circle.setRadius(radiusInMetres);
                EYA_CONF.zoom = zoomForRadius[radiusInMetres];
                map.setZoom((EYA_CONF.zoom) ? EYA_CONF.zoom : 12);
                updateMarkerPosition(marker.getPosition()); // so bookmarks is updated
                loadGroups();
            }
        );

        $('.tooltips').tooltip();

        // catch the link for "View all records"
        $('#viewAllRecords').on('click', function(e) {
            var params = 'q=*:*&lat=' + $('#latitude').val() + '&lon=' + $('#longitude').val() + '&radius=' + $('#radius').val();
            if(state.speciesGroup !== 'ALL_SPECIES') {
                params += '&fq=species_group:' + state.speciesGroup;
            }

            document.location.href = EYA_CONF.contextPath + '/occurrences/search?' + params;
        });

        // Catch enter key press on form
        $('#searchForm').bind('keypress', function(e) {
            if(e.keyCode === 13) {
                e.preventDefault();
                geocodeAddress();
            }
        });
    }

    function addTooltips() {
        $('#left-col a').tooltip();
    }

    /**
    * Google map API v3
    */
    function loadMap() {
        var latLng = new google.maps.LatLng($('#latitude').val(), $('#longitude').val());
        map = new google.maps.Map(document.getElementById('mapCanvas'), {
            zoom: EYA_CONF.zoom,
            center: latLng,
            scrollwheel: false,
            streetViewControl: true,
            mapTypeControl: true,
            mapTypeControlOptions: {
                style: google.maps.MapTypeControlStyle.DROPDOWN_MENU
            },
            navigationControl: true,
            navigationControlOptions: {
                style: google.maps.NavigationControlStyle.SMALL // DEFAULT
            },
            mapTypeId: google.maps.MapTypeId.HYBRID
        });
        marker = new google.maps.Marker({
            position: latLng,
            title: 'Marker Location',
            map: map,
            draggable: true
        });

        markerInfowindow = new google.maps.InfoWindow({
            content: '<div class="infoWindow">marker address</div>' // gets updated by geocodePosition()
        });

        google.maps.event.addListener(marker, 'click', function(event) {
            if(lastInfoWindow) {
                lastInfoWindow.close();
            }
            markerInfowindow.setPosition(event.latLng);
            markerInfowindow.open(map, marker);
            lastInfoWindow = markerInfowindow;
        });

        // Add a Circle overlay to the map.
        var radius = parseInt($('select#radius').val()) * 1010;
        circle = new google.maps.Circle({
            map: map,
            radius: radius,
            strokeWeight: 1,
            strokeColor: 'white',
            strokeOpacity: 0.5,
            fillColor: '#222', // '#2C48A6'
            fillOpacity: 0.2,
            zIndex: -10
        });
        // bind circle to marker
        circle.bindTo('center', marker, 'position');

        // Update current position info.
        geocodePosition(latLng);

        // Add dragging event listeners.
        google.maps.event.addListener(marker, 'dragstart', function() {
            updateMarkerAddress('Dragging...');
        });

        google.maps.event.addListener(marker, 'drag', function() {
            updateMarkerAddress('Dragging...');
        });

        google.maps.event.addListener(marker, 'dragend', function() {
            updateMarkerAddress('Drag ended');
            updateMarkerPosition(marker.getPosition());
            geocodePosition(marker.getPosition());
            loadGroups();
            map.panTo(marker.getPosition());
        });

        google.maps.event.addListener(map, 'zoom_changed', function() {
            loadRecordsLayer();
        });

        if(!points || points.length === 0) {
            loadRecordsLayer();
        }
    }

    /**
     * Google geocode function
     */
    function geocodePosition(pos) {
        geocoder.geocode({
            latLng: pos
        }, function(responses) {
            if(responses && responses.length > 0) {
                var address = responses[0].formatted_address;
                updateMarkerAddress(address);
                // update the info window for marker icon
                var content =
                    '<div class="infoWindow">' +
                        '<b>Your Location:</b>' +
                        '<br />' +
                        address +
                    '</div>';
                markerInfowindow.setContent(content);
            } else {
                updateMarkerAddress('Cannot determine address at this location.');
            }
        });
    }

    /**
     * Update the "address" hidden input and display span
     */
    function updateMarkerAddress(str) {
        $('#markerAddress').empty().html(str);
        $('#location').val(str);
        $('#dialog-confirm code').html(str); // download popup text
    }

    /**
     * Update the lat & lon hidden input elements
     */
    function updateMarkerPosition(latLng) {
        $('#latitude').val(latLng.lat());
        $('#longitude').val(latLng.lng());
        // Update URL hash for back button, etc
        location.hash = latLng.lat() + '|' + latLng.lng() + '|' + EYA_CONF.zoom + '|' + state.speciesGroup;
        $('#dialog-confirm #rad').html(EYA_CONF.radius);
    }

    /**
     * Load (reload) geoJSON data into vector layer
     */
    function loadRecordsLayer(retry) {
        if(!map && !retry) {
            // in case AJAX calls this function before map has initialised
            setTimeout(function() { if(!points || points.length === 0) { loadRecordsLayer(true); } }, 2000);
            return;
        } else if(!map) {
            return;
        }

        // URL for GeoJSON web service
        var geoJsonUrl = EYA_CONF.biocacheServiceUrl + '/geojson/radius-points.jsonp?callback=?';
        var zoom = (map && map.getZoom()) ? map.getZoom() : 12;
        // request params for ajax geojson call
        var params = {
            lat: $('#latitude').val(),
            lon: $('#longitude').val(),
            radius: $('#radius').val(),
            fq: 'geospatial_kosher:true',
            qc: EYA_CONF.queryContext,
            zoom: zoom
        };
        if(taxon) {
            params.q = 'taxon_name:\"' + taxon + '\"';
        } else {
            params.group = state.speciesGroup;
        }
        // JQuery AJAX call
        $.getJSON(geoJsonUrl, params, loadNewGeoJsonData);
    }

    /**
     * Callback for geoJSON ajax call
     */
    function loadNewGeoJsonData(data) {
        // clear vector featers and popups
        if(points && points.length > 0) {
            $.each(points, function(i, p) {
                p.setMap(null); // remove from map
            });
            points = [];
        } else {
            points = [];
        }

        if(infoWindows && infoWindows.length > 0) {
            $.each(infoWindows, function(i, n) {
                n.close(); // close any open popups
            });
            infoWindows = [];
        } else {
            infoWindows = [];
        }

        $.each(data.features, function(i, n) {
            var latLng1 = new google.maps.LatLng(n.geometry.coordinates[1], n.geometry.coordinates[0]);
            var iconUrl = EYA_CONF.imagesUrlPrefix + '/circle-' + n.properties.color.replace('#', '') + '.png';
            var markerImage = new google.maps.MarkerImage(iconUrl,
                new google.maps.Size(9, 9),
                new google.maps.Point(0, 0),
                new google.maps.Point(4, 5)
            );
            points[i] = new google.maps.Marker({
                map: map,
                position: latLng1,
                title: n.properties.count + ' occurrences',
                icon: markerImage
            });

            var solrQuery;
            if($.inArray('|', taxa) > 0) {
                var parts = taxa.split('|');
                var newParts = [];
                parts.forEach(function(j) {
                    newParts.push(rank + ':' + parts[j]);
                });
                solrQuery = newParts.join(' OR ');
            } else {
                solrQuery = '*:*'; // rank+':'+taxa;
            }
            var fqParam = '';
            if(taxonGuid) {
                fqParam = '&fq=species_guid:' + taxonGuid;
            } else if(state.speciesGroup !== 'ALL_SPECIES') {
                fqParam = '&fq=species_group:' + state.speciesGroup;
            }

            var content =
                '<div class="infoWindow">' +
                    'Number of records: ' + n.properties.count +
                    '<br />' +
                    '<a href="' + EYA_CONF.contextPath + '/occurrences/search?q=' + solrQuery + fqParam + '&lat=' + n.geometry.coordinates[1] + '&lon=' + n.geometry.coordinates[0] + '&radius=0.06">' +
                        '<span class="fa fa-list"></span> View records' +
                    '</a>' +
                '</div>';

            infoWindows[i] = new google.maps.InfoWindow({
                content: content,
                maxWidth: 200,
                disableAutoPan: false
            });
            google.maps.event.addListener(points[i], 'click', function(event) {
                if(lastInfoWindow) {
                    // close any previously opened infoWindow
                    lastInfoWindow.close();
                }
                infoWindows[i].setPosition(event.latLng);
                infoWindows[i].open(map, points[i]);
                lastInfoWindow = infoWindows[i]; // keep reference to current infoWindow
            });
        });

    }

    /**
     * Try to get a lat/long using HTML5 geoloation API
     */
    function attemptGeolocation() {
        // HTML5 GeoLocation
        if(navigator && navigator.geolocation) {
            function getMyPostion(position) {
                $('#mapCanvas').empty();
                updateMarkerPosition(new google.maps.LatLng(position.coords.latitude, position.coords.longitude));
                initialize();
            }

            function positionWasDeclined() {
                $('#mapCanvas').empty();
                updateMarkerPosition(new google.maps.LatLng($('#latitude').val(), $('#longitude').val()));
                initialize();
            }
            // Add message to browser - FF needs this as it is not easy to see
            var msg =
                'Waiting for confirmation to use your current location (see browser message at top of window)' +
                '<br />' +
                '<a href="#" onClick="loadMap(); return false;">' +
                    'Click here to load map' +
                '</a>';
            $('#mapCanvas').html(msg).css('color', 'red').css('font-size', '14px');
            navigator.geolocation.getCurrentPosition(getMyPostion, positionWasDeclined);
            // Neither functions gets called for some reason, so I've added a delay to initalize map anyway
            setTimeout(function() { if(!map) { positionWasDeclined(); } }, 9000);
        } else if(google.loader && google.loader.ClientLocation) {
            // Google AJAX API fallback GeoLocation
            updateMarkerPosition(new google.maps.LatLng(google.loader.ClientLocation.latitude, google.loader.ClientLocation.longitude));
            initialize();
        } else {
            EYA_CONF.zoom = 12;
            initialize();
        }
    }

    /**
     * Reverse geocode coordinates via Google Maps API
     */
    function geocodeAddress(reverseGeocode) {
        var address = $('input#address').val();
        var latLng = null;

        // Check if input contains a comma and try and patch coordinates
        if(address && address.indexOf(',') > -1 && window.magellan) {
            var parts = address.split(',');
            var lat = window.magellan(parts[0].trim()).latitude(); // .toDD();
            var lng = window.magellan(parts[1].trim()).longitude(); // .toDD();

            if(lat && lng) {
                latLng = new google.maps.LatLng(lat.toDD(), lng.toDD());
                updateMarkerAddress('GPS corrdinates: ' + lat.toDD() + ', ' + lng.toDD());
                updateMarkerPosition(latLng);
                // reload map pin, etc
                initialize();
                loadRecordsLayer();
            }

        }

        if(!latLng && geocoder && address) {
            geocoder.geocode({ 'address': address, region: 'AU' }, function(results, status) {
                if(status === google.maps.GeocoderStatus.OK) {
                    // geocode was successful
                    updateMarkerAddress(results[0].formatted_address);
                    updateMarkerPosition(results[0].geometry.location);
                    // reload map pin, etc
                    initialize();
                    loadRecordsLayer();
                } else {
                    alert('Geocode was not successful for the following reason: ' + status);
                }
            });
        } else {
            initialize();
        }
    }

    /**
     * Species group was clicked
     */
    function groupClicked(el) {
        // Change the global var speciesGroup
        state.speciesGroup = $(el).attr('data-taxon-name');
        taxon = null; // clear any species click
        taxonGuid = null;
        $('#taxa-level-0 tr').removeClass('activeRow');
        $(el).addClass('activeRow');
        $('#taxa-level-1 tbody tr').addClass('activeRow');
        $('#rightList tbody').empty();
        // load records layer on map
        // update links to downloads and records list

        if(map) {
            loadRecordsLayer();
        }
        // AJAX...
        var uri = EYA_CONF.biocacheServiceUrl + '/explore/group/' + state.speciesGroup + '.json?callback=?';
        var params = {
            lat: $('#latitude').val(),
            lon: $('#longitude').val(),
            radius: $('#radius').val(),
            fq: 'geospatial_kosher:true',
            qc: EYA_CONF.queryContext,
            pageSize: 50
        };
        $('#taxaDiv').html('[loading...]');
        $.getJSON(uri, params, function(data) {
            // process JSON data from request
            if(data) {
                processSpeciesJsonData(data);
            }
        });
    }

    var sortOrder;  // Keep the last used ordering state for the right panel

    /**
     * Process the JSON data from an Species list AJAX request (species in area)
     */
    function processSpeciesJsonData(data) {
        // clear right list unless we're paging
        var newStart = 0;
        // process JSON data
        if(data.length > 0) {
            var lastRow = $('#rightList tbody tr').length;
            var infoTitle = 'view species page';
            var recsTitle = 'view list of records';
            // iterate over list of species from search
            var i = 0;
            data.forEach(function(taxon) {
                // create new table row
                var count = i + lastRow;
                i++;
                // add count
                var tr =
                    '<tr id="' + taxon.guid + '" data-taxon-name="' + taxon.name + '">' +
                        '<td class="speciesIndex">' +
                            (count + 1) + '.' +
                        '</td>' +
                        '<td class="sciName">' +
                            '<i>' +
                                taxon.name +
                            '</i>';
                // add common name
                if(taxon.commonName) {
                    tr += ' : ' + taxon.commonName;
                }
                // add links to species page and ocurrence search (inside hidden div)
                var speciesInfo = '<div class="speciesInfo">';
                if(taxon.guid) {
                    speciesInfo +=
                        '<a title="' + infoTitle + '" href="' + EYA_CONF.speciesPageUrl + taxon.guid + '">' +
                            '<span class="fa fa-tag"></span> Species page' +
                        '</a> | ';
                }
                speciesInfo +=
                        '<a href="' + EYA_CONF.contextPath + '/occurrences/search?q=taxon_name:%22' + taxon.name +
                            '%22&lat=' + $('input#latitude').val() + '&lon=' + $('input#longitude').val() + '&radius=' + $('select#radius').val() + '" title="' +
                            recsTitle + '"' +
                        '>' +
                            '<span class="fa fa-list"></span> View records' +
                        '</a>' +
                    '</div>';
                tr += speciesInfo;
                // add number of records
                tr += '</td><td class="rightCounts">' + taxon.count + ' </td></tr>';
                // write list item to page
                $('#rightList tbody').append(tr);
            });

            if(data.length === 50) {
                // add load more link
                newStart = $('#rightList tbody tr').length;
                var loadMore =
                    '<tr id="loadMoreRow">' +
                        '<td>&nbsp;</td>' +
                        '<td colspan="2"> ' +
                            '<button id="loadMoreSpecies" class="erk-link-button">' +
                                'Load more&hellip;' +
                            '</button>' +
                        '</td>' +
                    '</tr>';
                $('#rightList tbody').append(loadMore);
            }
        } else {
            // no spceies were found (either via paging or clicking on taxon group
            var text = '<tr><td></td><td colspan="2">[no species found]</td></tr>';
            $('#rightList tbody').append(text);
        }

        // Register clicks for the list of species links so that map changes
        $('#rightList tbody tr').click(function(e) {
            if(this.id === 'loadMoreRow') {
                return;
            }
            var thisTaxon = $(this).attr('data-taxon-name');
            var guid = $(this).attr('id');
            taxonGuid = guid;
            taxon = thisTaxon; // global var so map can show just this taxon
            $('#rightList tbody tr').removeClass('activeRow2'); // un-highlight previous current taxon
            // remove previous species info row
            $('#rightList tbody tr#info').detach();
            var info = $(this).find('.speciesInfo').html();
            // copy contents of species into a new (tmp) row
            if(info) {
                $(this).after('<tr id="info"><td><td>' + info + '<td></td></tr>');
            }
            // hide previous selected spceies info box
            $(this).addClass('activeRow2'); // highloght current taxon
            // show the links for current selected species
            loadRecordsLayer();
        });

        // Register onClick for "load more species" link & sort headers
        $('#loadMoreSpecies, .fixedHeader button').off().click(function(e) {
            if(this.id !== 'loadMoreSpecies') {
                $('#rightList tbody').empty();
                sortOrder = $(this).data('sort') ? $(this).data('sort') : 'index';
                newStart = 0;
            }

            var sortParam = sortOrder;
            var commonName = false;
            if(sortOrder === 'common') {
                commonName = true;
                sortParam = 'index';
            }

            // AJAX...
            var uri = EYA_CONF.biocacheServiceUrl + '/explore/group/' + state.speciesGroup + '.json?callback=?';
            var params = {
                lat: $('#latitude').val(),
                lon: $('#longitude').val(),
                radius: $('#radius').val(),
                fq: 'geospatial_kosher:true',
                start: newStart,
                common: commonName,
                sort: sortParam,
                pageSize: 50,
                qc: EYA_CONF.queryContext
            };
            $('#loadMoreRow').detach(); // delete it
            $.getJSON(uri, params, function(data) {
                // process JSON data from request
                processSpeciesJsonData(data);
            });
        });

        // add hover effect to table cell with scientific names
        $('#rightList tbody tr').hover(
            function() {
                $(this).addClass('hoverCell');
            },
            function() {
                $(this).removeClass('hoverCell');
            }
        );
    }

    /*
     * Perform normal spatial searcj for spceies groups and species counts
     */
    function loadGroups() {
        var url = EYA_CONF.biocacheServiceUrl + '/explore/groups.json?callback=?';
        var params = {
            lat: $('#latitude').val(),
            lon: $('#longitude').val(),
            radius: $('#radius').val(),
            fq: 'geospatial_kosher:true',
            facets: 'species_group',
            qc: EYA_CONF.queryContext
        };

        $.getJSON(url, params, function(data) {
            if(data) {
                populateSpeciesGroups(data);
            }
        });
    }

    /*
     * Populate the spceies group column (via callback from AJAX)
     */
    function populateSpeciesGroups(data) {
        if(data.length > 0) {
            $('#taxa-level-0 tbody').empty(); // clear existing values
            $.each(data, function(i, n) {
                addGroupRow(n.name, n.speciesCount, n.level);
            });

            // Dynamically set height of #taxaDiv (to match containing div height)
            var tableHeight = $('#taxa-level-0').height();
            $('.tableContainer').height(tableHeight + 2);
            var tbodyHeight = $('#taxa-level-0 tbody').height();
            $('#rightList tbody').height(tbodyHeight);
            $('#taxa-level-0 tbody tr.activeRow').click();
        }

        function addGroupRow(taxonName, count, indent) {
            var label = taxonName;
            if(taxonName === 'ALL_SPECIES') {
                label = 'All Species';
            }
            var rc = (taxonName === state.speciesGroup) ? ' class=\'activeRow\'' : ''; // highlight active taxonName
            var h =
                '<tr' + rc + ' title="click to view group on map" data-taxon-name="' + taxonName + '">' +
                    '<td class="indent' + indent + '">' +
                        label +
                    '</td>' +
                    '<td>' + count + '</td>' +
                '</tr>';
            $('#taxa-level-0 tbody').append(h);
        }
    }

    function bookmarkedSearch(lat, lng, zoom1, group) {
        EYA_CONF.radius = radiusForZoom[zoom1];  // set global var
        EYA_CONF.zoom = parseInt(zoom1);
        $('select#radius').val(EYA_CONF.radius); // update drop-down widget
        if(group) {
            state.speciesGroup = group;
        }
        updateMarkerPosition(new google.maps.LatLng(lat, lng));
        // load map and groups
        initialize();
    }

    return state;
}
