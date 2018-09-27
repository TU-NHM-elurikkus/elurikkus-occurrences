// Note there are some global variables that are set by the calling page (which has access to
// the ${pageContet} object, which are required by this file.:

function loadExploreArea(EYA_CONF) {
    var state = {
        speciesGroup: 'ALL_SPECIES'
    };

    var geocoder, map, marker, circle, markerInfowindow, lastInfoWindow, taxonGuid;
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
    });

    // var proj900913 = new OpenLayers.Projection("EPSG:900913");
    // var proj4326 = new OpenLayers.Projection("EPSG:4326");

    // pointer fn
    function initialize() {
        loadMap();
        loadGroups();
    }

    function registerEventHandlers() {
        // Register events for the species_group column
        $('#leftList tbody tr').live('mouseover mouseout', function(event) {
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

        // catch the link for "View all records"
        $('#viewAllRecords').on('click', function(e) {
            var params = 'lat=' + $('#latitude').val() + '&lon=' + $('#longitude').val() + '&radius=' + $('#radius').val();
            if(state.speciesGroup !== 'ALL_SPECIES') {
                params += '&q=text:' + state.speciesGroup;
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

        $('[data-toggle="tooltip"]').tooltip({
            delay: { 'show': 1000, 'hide': 100 },
            trigger: 'hover'
        });
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
            title: $.i18n.prop('eya.map.marker.title'),
            map: map,
            draggable: true
        });

        markerInfowindow = new google.maps.InfoWindow({
            content:
                '<div class="infoWindow">' +
                    $.i18n.prop('eya.map.marker.address') +
                '</div>' // gets updated by geocodePosition()
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
            updateMarkerAddress($.i18n.prop('eya.map.dragging') + '&hellip;');
        });

        google.maps.event.addListener(marker, 'drag', function() {
            updateMarkerAddress($.i18n.prop('eya.map.dragging') + '&hellip;');
        });

        google.maps.event.addListener(marker, 'dragend', function() {
            updateMarkerAddress($.i18n.prop('eya.map.dragEnd'));
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
                        '<b>' +
                            $.i18n.prop('eya.map.marker.location') + ':' +
                        '</b>' +
                        '<br />' +
                        address +
                    '</div>';
                markerInfowindow.setContent(content);
            } else {
                updateMarkerAddress($.i18n.prop('eya.map.marker.noLocation'));
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
            setTimeout(function() {
                if(!points || points.length === 0) {
                    loadRecordsLayer(true);
                }
            }, 2000);
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
            qc: EYA_CONF.queryContext,
            zoom: zoom
        };
        if(state.speciesGroup !== 'ALL_SPECIES') {
            params.fq = state.taxonRank + ':' + state.speciesGroup;
        }

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
                title: n.properties.count + ' ' + $.i18n.prop('eya.map.nrOccurrences'),
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
                    $.i18n.prop('eya.speciesTable.header.count.label') + ': ' + n.properties.count +
                    '<br />' +
                    '<a href="' + EYA_CONF.contextPath + '/occurrences/search?q=' + solrQuery + fqParam + '&lat=' + n.geometry.coordinates[1] + '&lon=' + n.geometry.coordinates[0] + '&radius=0.06">' +
                        '<span class="fa fa-list"></span>' +
                        '&nbsp;' +
                        $.i18n.prop('general.btn.viewRecords') +
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
                '<span style="color: red; font-size: 14px">' +
                    $.i18n.prop('eya.map.waitingConfirm') +
                '</span>' +
                '<br />' +
                '<a href="#" onClick="loadMap(); return false;">' +
                    $.i18n.prop('eya.map.helpText') +
                '</a>';
            $('#mapCanvas').html(msg);
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

        if(geocoder && address) {
            geocoder.geocode({ 'address': address, region: 'AU' }, function(results, status) {
                if(status === google.maps.GeocoderStatus.OK) {
                    // geocode was successful
                    updateMarkerAddress(results[0].formatted_address);
                    updateMarkerPosition(results[0].geometry.location);
                    // reload map pin, etc
                    initialize();
                    loadRecordsLayer();
                } else {
                    // TODO Handle empty results response.
                    console.error(status);
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
        state.taxonRank = $(el).attr('data-taxon-rank');
        taxonGuid = null;

        if($(el).attr('data-taxon-name') === 'ALL_SPECIES') {
            $('#viewAllRecords').html(
                '<span class="fa fa-list"></span>' +
                '&nbsp;' +
                $.i18n.prop('eya.searchform.viewAllRecords.label')
            );
        } else {
            $('#viewAllRecords').html(
                '<span class="fa fa-list"></span>' +
                '&nbsp;' +
                $.i18n.prop('eya.searchform.viewSelectedRecords.label')
            );
        }

        // Hide all subgroups if main group is changed
        if($(el).hasClass('mainGroup')) {
            $('[data-parent-taxon]').css('visibility', 'collapse');
            $('.mainGroup').removeClass('activeRow');
            $('.mainGroup span').removeClass('fa-chevron-down').addClass('fa-chevron-right');
            $(el).find('span').removeClass('fa-chevron-right').addClass('fa-chevron-down');

            var subRows = $('[data-parent-taxon="' + state.speciesGroup + '"]');
            subRows.css('visibility', 'visible');

            // Get species counts
            populateTaxonRowCounts(subRows);
        }

        $('[data-parent-taxon]').removeClass('activeRow');
        $(el).addClass('activeRow');
        $('#rightList tbody').empty();
        // load records layer on map
        // update links to downloads and records list

        if(map) {
            loadRecordsLayer();
        }
        // AJAX...
        var uri = EYA_CONF.biocacheServiceUrl + '/explore/group/ALL_SPECIES.json?callback=?';
        var params = {
            lat: $('#latitude').val(),
            lon: $('#longitude').val(),
            radius: $('#radius').val(),
            qc: EYA_CONF.queryContext,
            pageSize: 50
        };
        if(state.speciesGroup !== 'ALL_SPECIES') {
            params.fq = state.taxonRank + ':' + state.speciesGroup;
        }
        $.getJSON(uri, params, function(data) {
            // process JSON data from request
            if(data) {
                processSpeciesJsonData(data);
            }
        });
    }

    function populateTaxonRowCounts(rows) {
        rows.each(function(index, row) {
            var taxonQuery = '';
            if(row.dataset.taxonName !== 'ALL_SPECIES') {
                taxonQuery = row.dataset.taxonRank + ':"' + row.dataset.taxonName + '"';
            }
            var url = EYA_CONF.contextPath + '/proxy/explore/counts/group/ALL_SPECIES/';
            $.ajax({
                url: url,
                dataType: 'json',
                cache: true,
                data: {
                    'lat': $('#latitude').val(),
                    'lon': $('#longitude').val(),
                    'radius': $('#radius').val(),
                    'fq': taxonQuery,
                },
                success: function(data) {
                    $(row.children[1]).html(data[1]);
                },
            });
        });
    }

    var sortOrder; // Keep the last used ordering state for the right panel

    /**
     * Process the JSON data from an Species list AJAX request (species in area)
     */
    function processSpeciesJsonData(data) {
        // clear right list unless we're paging
        var newStart = 0;
        // process JSON data
        if(data.length > 0) {
            var lastRow = $('#rightList tbody tr').length;
            var infoTitle = $.i18n.prop('eya.speciesTable.viewSpecies');
            var recsTitle = $.i18n.prop('general.btn.viewRecords');
            // iterate over list of species from search
            data.forEach(function(taxon, i) {
                // create new table row
                var count = i + lastRow;
                // add count
                var tr =
                    '<tr id="' + taxon.guid + '" data-taxon-name="' + taxon.name + '" data-taxon-guid="">' +
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
                            '<span class="fa fa-tag"></span>' +
                            '&nbsp;' +
                            infoTitle +
                        '</a> | ';
                }
                speciesInfo +=
                        '<a href="' + EYA_CONF.contextPath + '/occurrences/search?q=taxon_name:%22' + taxon.name +
                            '%22&lat=' + $('input#latitude').val() + '&lon=' + $('input#longitude').val() + '&radius=' + $('select#radius').val() + '" title="' +
                            recsTitle + '"' +
                        '>' +
                            '<span class="fa fa-list"></span>' +
                            '&nbsp;' +
                            recsTitle +
                        '</a>' +
                    '</div>';

                tr +=
                            speciesInfo +
                        '</td>' +
                        '<td class="rightCounts">' +
                            taxon.count +
                        '</td>' +
                    '</tr>';

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
                                $.i18n.prop('general.btn.loadMore') +
                            '</button>' +
                        '</td>' +
                    '</tr>';
                $('#rightList tbody').append(loadMore);
            }
        } else {
            // no spceies were found (either via paging or clicking on taxon group
            var text =
                '<tr>' +
                    '<td></td>' +
                    '<td colspan="2">' +
                        '[' + $.i18n.prop('eya.search.noSpecies') + ']' +
                    '</td>' +
                '</tr>';
            $('#rightList tbody').append(text);
        }

        // Register clicks for the list of species links so that map changes
        $('#rightList tbody tr').click(function(e) {
            if(this.id === 'loadMoreRow') {
                return;
            }
            // var thisTaxon = $(this).attr('data-taxon-name');
            state.speciesGroup = $(this).attr('data-taxon-name');
            state.taxonRank = 'species';
            var guid = $(this).attr('id');
            taxonGuid = guid;
            // taxon = thisTaxon; // global var so map can show just this taxon
            $('#rightList tbody tr').removeClass('activeRow2'); // un-highlight previous current taxon
            // remove previous species info row
            $('#rightList tbody tr#species-info').detach();
            var info = $(this).find('.speciesInfo').html();
            // copy contents of species into a new (tmp) row
            if(info) {
                $(this).after('<tr id="species-info"><td><td>' + info + '<td></td></tr>');
            }
            // hide previous selected spceies info box
            $(this).addClass('activeRow2'); // highloght current taxon
            // show the links for current selected species
            loadRecordsLayer();
        });

        // Register onClick for "load more species" link & sort headers
        $('#loadMoreSpecies, #right-table-header button').off().click(function(e) {
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
            var uri = EYA_CONF.biocacheServiceUrl + '/explore/group/ALL_SPECIES.json?callback=?';
            var params = {
                lat: $('#latitude').val(),
                lon: $('#longitude').val(),
                radius: $('#radius').val(),
                start: newStart,
                common: commonName,
                sort: sortParam,
                pageSize: 50,
                qc: EYA_CONF.queryContext
            };

            if(state.speciesGroup !== 'ALL_SPECIES') {
                params.fq = state.taxonRank + ':' + state.speciesGroup;
            }

            $('#loadMoreRow').detach(); // delete it
            $.getJSON(uri, params, function(data) {
                // process JSON data from request
                processSpeciesJsonData(data);
            });
        });

        // add hover effect to table cell with scientific names
        $('#rightList tbody tr').hover(
            function() {
                $(this).addClass('hoverRow');
            },
            function() {
                $(this).removeClass('hoverRow');
            }
        );
    }

    /*
     * Perform normal spatial search for spceies groups and species counts
     */
    function loadGroups() {
        var url = EYA_CONF.biocacheServiceUrl + '/explore/hierarchy.json?callback=?';
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
        $('#leftList tbody').empty(); // clear existing values
        addGroupRow('ALL_SPECIES', '', '');

        data.forEach(function(n) {
            addGroupRow(n.speciesGroup, n.common, n.taxonRank);
            n.taxa.forEach(function(subTaxon) {
                addSubGroupRow(subTaxon.name, subTaxon.common, subTaxon.taxonRank, n.speciesGroup);
            });
        });

        // Get species counts
        var mainRows = $('.mainGroup');
        populateTaxonRowCounts(mainRows);

        $('[data-taxon-name="ALL_SPECIES"]').click();

        function addGroupRow(taxonName, common, taxonRank) {
            if(GLOBAL_LOCALE_CONF.locale !== 'et') {
                common = taxonName;
            }
            if(taxonName === 'ALL_SPECIES') {
                common = $.i18n.prop('eya.search.allSpecies');
            }

            var h =
                '<tr class="mainGroup" data-taxon-name="' + taxonName + '" data-taxon-rank="' + taxonRank + '">' +
                    '<td>' +
                        '<span class="fa fa-chevron-right"></span>&nbsp;' + common +
                    '</td>' +
                    '<td class="speciesCount">' +
                        '##' +
                    '</td>' +
                '</tr>';
            $('#leftList tbody').append(h);
        }

        function addSubGroupRow(taxonName, common, taxonRank, parentTaxon) {
            if(GLOBAL_LOCALE_CONF.locale !== 'et') {
                common = taxonName;
            }
            var h =
                '<tr data-taxon-name="' + taxonName + '" data-taxon-rank="' + taxonRank + '" data-parent-taxon="' + parentTaxon + '" style="visibility:collapse;">' +
                    '<td class="subGroupRow">' +
                        common +
                    '</td>' +
                    '<td class="speciesCount">' +
                        '##' +
                    '</td>' +
                '</tr>';
            $('#leftList tbody').append(h);
        }
    }

    function bookmarkedSearch(lat, lng, zoom1, group) {
        EYA_CONF.radius = radiusForZoom[zoom1]; // set global var
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
