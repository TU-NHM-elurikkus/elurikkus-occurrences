var BC_CONF;  // Populated by elurikkus.gsp inline script

// Jquery Document.onLoad equivalent
$(document).ready(function() {
    // listeners for sort & paging widgets
    $('select#sort').change(function() {
        var val = $('option:selected', this).val();
        reloadWithParam('sort', val);
    });
    $('select#dir').change(function() {
        var val = $('option:selected', this).val();
        reloadWithParam('dir', val);
    });
    $('select#sort').change(function() {
        var val = $('option:selected', this).val();
        reloadWithParam('sort', val);
    });
    $('select#dir').change(function() {
        var val = $('option:selected', this).val();
        reloadWithParam('dir', val);
    });
    $('select#per-page').change(function() {
        var val = $('option:selected', this).val();
        reloadWithParam('pageSize', val);
    });

    // Jquery Tools Tabs setup
    var tabsInit = {
        map: false,
        charts: false,
        userCharts: false,
        images: false,
        species: false
    };

    // initialise BS tabs
    $('a[data-toggle="tab"]').on('shown.bs.tab', function(e) {
        var id = $(this).attr('id');
        var tab = $(e.target).attr('href').replace('tab-', '');

        amplify.store('search-tab-state', tab.substr(1));

        if(window.history) {
            window.history.replaceState({}, '', tab);
        } else {
            window.location.hash = tab;
        }

        if(id === 't2' && !tabsInit.map) {
            initialiseMap();
            tabsInit.map = true; // only initialise once!
        } else if(id === 't3' && !tabsInit.charts) {
            // trigger charts load
            loadDefaultCharts();
            tabsInit.charts = true; // only initialise once!
        } else if(id === 't6' && !tabsInit.userCharts) {
            // trigger charts load
            loadUserCharts();
            tabsInit.userCharts = true; // only initialise once!
        } else if(id === 't4' && !tabsInit.species) {
            loadSpeciesInTab(0, 'common');
            tabsInit.species = true;
        } else if(id === 't5' && !tabsInit.images && BC_CONF.hasMultimedia) {
            loadImagesInTab();
            tabsInit.images = true;
        }
    });

    var storedSearchTab = amplify.store('search-tab-state');

    // work-around for intitialIndex & history being mutually exclusive
    if(!storedSearchTab && BC_CONF.defaultListView && !window.location.hash) {
        window.location.hash = BC_CONF.defaultListView; // used for avh, etc
    }

    // catch hash URIs and trigger tabs
    if(location.hash !== '') {
        $('.nav-tabs a[href="#tab-' + location.hash.substr(1) + '"]').tab('show');
    } else if(storedSearchTab) {
        $('.nav-tabs a[href="#tab-' + storedSearchTab + '"]').tab('show');
    } else {
        $('.nav-tabs a:first').tab('show');
    }

    // Substitute LSID strings for taxon names in facet values for species
    var guidList = [];
    $('li.species_guid, li.genus_guid').each(function(i, el) {
        guidList[i] = $(el).attr('id');
    });

    if(guidList.length > 0) {
        // AJAX call to get names for LSIDs
        // IE7< has limit of 2000 chars on URL so split into 2 requests
        var guidListA = guidList.slice(0, 15); // first 15 elements
        var jsonUrlA = BC_CONF.bieWebappUrl + '/species/namesFromGuids.json?guid=' + guidListA.join('&guid=') + '&callback=?';
        $.getJSON(jsonUrlA, function(data) {
            // set the name in place of LSID
            $('li.species_guid, li.genus_guid').each(function(i, el) {
                if(i < 15) {
                    $(el).find('a').html('<i>' + data[i] + '</i>');
                } else {
                    return false; // breaks each loop
                }
            });
        });

        if(guidList.length > 15) {
            var guidListB = guidList.slice(15);
            var jsonUrlB = BC_CONF.bieWebappUrl + '/species/namesFromGuids.json?guid=' + guidListB.join('&guid=') + '&callback=?';
            $.getJSON(jsonUrlB, function(data) {
                // set the name in place of LSID
                $('li.species_guid, li.genus_guid').each(function(i, el) {
                    // skip forst 15 elements
                    if(i > 14) {
                        var k = i - 15;
                        $(el).find('a').html('<i>' + data[k] + '</i>');
                    }
                });
            });
        }
    }

    // do the same for the selected facet
    var selectedLsid = $('b.species_guid').attr('id');
    if(selectedLsid) {
        var jsonUrl2 = BC_CONF.bieWebappUrl + '/species/namesFromGuids.json?guid=' + selectedLsid + '&callback=?';
        $.getJSON(jsonUrl2, function(data) {
            // set the name in place of LSID
            $('b.species_guid').html('<i>' + data[0] + '</i>');
        });
    }

    // remove *:* query from search bar
    var q = $.url().param('q');
    if(q && q[0] === '*:*') {
        $(':input#solrQuery').val('');
    }

    // active facets/filters
    $('#clear-filters-btn').click(function(e) {
        e.preventDefault();
        removeFilter(this);
    });

    // TODO: Change ID/class.
    // bootstrap dropdowns - allow clicking inside dropdown div
    $('#customiseFilters').children().not('#updateFacetOptions').click(function(e) {
        e.stopPropagation();
    });

    // TODO: Remove or rewrite.
    // in mobile view toggle display of facets
    $('#toggleFacetDisplay').click(function() {
        $(this).find('i').toggleClass('icon-chevron-down icon-chevron-right');
        if($('.sidebar').is(':visible')) {
            $('.sidebar').removeClass('overrideHide');
        } else {
            $('.sidebar').addClass('overrideHide');
        }
    });

    // user selectable facets...
    $('#updateFacetOptions').click(function(e) {
        e.preventDefault();

        var selectedFacets = [];

        // iterate over seleted facet options
        $(':input.search-filter-checkbox__label__input:checked').each(function(i, el) {
            selectedFacets.push($(el).val());
        });

        // Check user has selected at least 1 facet
        if(selectedFacets.length > 0) {
            // save facets to the user_facets cookie
            $.cookie('user_facets', selectedFacets, { expires: 7 });
            // reload page
            document.location.reload(true);
        } else {
            alert('Please select at least one filter category to display');
        }

    });

    // reset facet options to default values (clear cookie)
    $('#resetFacetOptions').click(function(e) {
        e.preventDefault();
        $.removeCookie('user_facets');
        document.location.reload(true);
    });

    // load stored prefs from cookie
    var userFacets = $.cookie('user_facets');
    if(userFacets) {
        $(':input.search-filter-checkbox__label__input').removeAttr('checked');
        var facetList = userFacets.split(',');
        for(var i in facetList) {
            if(typeof facetList[i] === 'string') {
                var thisFacet = facetList[i];
                $(':input.search-filter-checkbox__label__input[value="' + thisFacet + '"]').attr('checked', 'checked');
            }
        }
    } //  note removed else that did page refresh by triggering cookie update code.

    // select all and none buttons
    $('#selectNone').click(function(e) {
        e.preventDefault();
        $(':input.search-filter-checkbox__label__input').removeAttr('checked');
    });

    // XXX BLOODY HELL
    $('#selectAll').click(function(e) {
        e.preventDefault();
        $(':input.search-filter-checkbox__label__input').attr('checked', 'checked');
    });

    // taxa search - show included synonyms with popup to allow user to refine to a single name
    $('span.lsid').not('.searchError, .lsid').each(function(i, el) {
        var lsid = $(this).attr('id');
        var nameString = $(this).html();
        var maxFacets = 20;
        var index = i; // keep a copy
        var queryContextParam = (BC_CONF.queryContext) ? '&qc=' + BC_CONF.queryContext : '';
        var jsonUri = BC_CONF.biocacheServiceUrl + '/occurrences/search.json?q=lsid:' + lsid + '&' + BC_CONF.facetQueries +
            '&facets=raw_taxon_name&pageSize=0&flimit=' + maxFacets + queryContextParam + '&callback=?';

        var $clone = $('#resultsReturned #template').clone();
        $clone.attr('id', ''); // remove the ID
        $clone.find('.taxaMenuContent').addClass('stopProp');
        // add unique IDs to some elements
        $clone.find('form.raw_taxon_search').attr('id', 'rawTaxonSearch_' + i);
        $clone.find(':input.rawTaxonSumbit').attr('id', 'rawTaxonSumbit_' + i);
        $clone.find('.refineTaxaSearch').attr('id', 'refineTaxaSearch_' + i);

        $.getJSON(jsonUri, function(data) {
            // use HTML template, see http://stackoverflow.com/a/1091493/249327
            var speciesPageUri = BC_CONF.bieWebappUrl + '/species/' + lsid;
            var speciesPageLink =
                '<a href="' + speciesPageUri + '" title="Species page" target="BIE">' +  // TODO: Translate
                    'view species page' +  // TODO: Translate
                '</a>';
            $clone.find('a.erk-button').text(nameString).attr('href', speciesPageUri);
            $clone.find('.nameString').text(nameString);
            $clone.find('.speciesPageLink').html(speciesPageLink);

            var synListSize = 0;
            var synList1 = '';
            $.each(data.facetResults, function(k, el) {
                if(el.fieldName === 'raw_taxon_name') {
                    $.each(el.fieldResult, function(j, el1) {
                        synListSize++;
                        synList1 +=
                            '<input type="checkbox" name="raw_taxon_guid" id="rawTaxon_' + index + '_' + j + '" class="rawTaxonCheckBox" value="' + el1.label + '" />' +
                            '&nbsp;' +
                            '<a href="' + BC_CONF.contextPath + '/occurrences/search?q=raw_taxon_name:%22' + el1.label + '%22" >' +
                                el1.label +
                            '</a>' +
                            ' (' + el1.count + ')' +
                            '<br />';
                    });
                }
            });

            if(synListSize === 0) {
                synList1 += '[no records found]';
            }

            if(synListSize >= maxFacets) {
                synList1 +=
                    '<div>' +
                        '<br />' +
                        'Only showing the first ' + maxFacets + ' names' +
                        '<br />' +
                        'See the "Scientific name (unprocessed)" section in the "Refine results" column on the left for a complete list' +
                    '</div>';
            }

            $clone.find('div.rawTaxaList').html(synList1);
            $clone.removeClass('hide'); // XXX This won't work.
            // prevent BS dropdown from closing when clicking on content
            $clone.find('.stopProp').children().not('input.rawTaxonSumbit').click(function(e) {
                e.stopPropagation();
            });

            // $('#rawTaxonSearchForm').append(synList);
            // position it under the drop down
            // $('#refineTaxaSearch_'+i).position({
                // my: 'right top',
                // at: 'right bottom',
                // of: $(el), // or this
                // offset: '0 -1',
                // collision: 'none'
            // });
            // $('#refineTaxaSearch_'+i).hide();
        });

        // format display with drop-down
        // $('span.lsid').before('<span class='plain'> which matched: </span>');
        // $(el).html('<a href='#' title='click for details about this taxon search' id='lsid_' + i + ''>' + nameString + '</a>');
        // $(el).addClass('dropDown');
        $(el).html($clone);
    });

    // form validation for raw_taxon_name popup div with checkboxes
    $(':input.rawTaxonSumbit').on('click', function(e) {
        e.preventDefault();
        var submitId = $(this).attr('id');
        var formNum = submitId.replace('rawTaxonSumbit_', ''); // 1, 2, etc
        var checkedFound = false;

        $('#refineTaxaSearch_' + formNum).find(':input.rawTaxonCheckBox').each(function(i, el) {
            if($(el).is(':checked')) {
                checkedFound = true;
                return false;  // break loop
            }
        });

        if(checkedFound) {
            $(this.form).submit();
        } else {
            alert('Please check at least one "verbatim scientific name" checkbox');
        }
    });

    // load more images button
    $('#loadMoreImages .erk-button').live('click', function(e) {
        e.preventDefault();
        $(this).addClass('disabled');
        $(this).find('img').show();  // turn on spinner
        var start = $('#imagesGrid').data('count');
        loadImages(start);
    });

    $('.multipleFacetsLink').click(function() {
        var link = this;
        var facetName = link.id
            .replace('multi-', '')
            .replace('_guid', '')
            .replace('_uid', '_name')
            .replace('data_resource_name', 'data_resource_uid')
            .replace('data_provider_name', 'data_provider_uid')
            .replace('species_list_name', 'species_list_uid')
            .replace('occurrence_year', 'decade');

        var displayName = $(link).data('displayname');
        loadMoreFacets(facetName, displayName, null);
    });

    $('#multipleFacets').on('hidden.bs.modal', function() {
        // clear the tbody content
        $('tbody.scrollContent tr').not('#spinnerRow').remove();
    });

    $('#downloadFacet').live('click', function(e) {
        var facetName = $('#fullFacets').data('facet');
        window.location.href = BC_CONF.biocacheServiceUrl + '/occurrences/facets/download' +
            BC_CONF.facetDownloadQuery +
            '&facets=' + facetName +
            '&count=true';
    });

    // form validation for form#facetRefineForm
    $('#submitFacets :input.submit').live('click', function(e) {
        e.preventDefault();
        var inverseModifier = ($(this).attr('id') === 'exclude') ? '-' : '';
        var fq = ''; // build up OR'ed fq query
        var checkedFound = false;
        var selectedCount = 0;
        var maxSelected = 15;
        $('form#facetRefineForm').find(':input.fqs').each(function(i, el) {
            if($(el).is(':checked')) {
                checkedFound = true;
                selectedCount++;
                fq += $(el).val() + ' OR ';
            }
        });
        fq = fq.replace(/ OR $/, ''); // remove trailing OR

        if(fq.indexOf(' OR ') !== -1) {
            fq = '(' + fq + ')';  // so that exclude (inverse) searches work
        }

        if(checkedFound && selectedCount > maxSelected) {
            alert('Too many options selected - maximum is ' + maxSelected + ', you have selected ' + selectedCount + ', please de-select ' +
                (selectedCount - maxSelected) + ' options. \n\nNote: if you want to include/exclude all possible values (wildcard filter), use the drop-down option on the buttons below.');
        } else if(checkedFound) {
            var hash = window.location.hash;
            var fqString = '&fq=' + inverseModifier + fq;
            window.location.href = window.location.pathname + BC_CONF.searchString + fqString + hash;
        } else {
            alert('Please select at least one checkbox.');
        }
    });

    // Drop-down option on facet popup div - for wildcard fq searches
    $('#submitFacets a.wildcard').live('click', function(e) {
        e.preventDefault();
        var link = this;
        var inverseModifier = ($(link).attr('id').indexOf('exclude') !== -1) ? '-' : '';
        var facetName = $('#fullFacets').data('facet');
        var fqString = '&fq=' + inverseModifier + facetName + ':*';
        window.location.href = window.location.pathname + BC_CONF.searchString + fqString;
    });

    $('a.multipleFacetsLink, a#downloadLink, a#alertsLink, .tooltips, .tooltip, span.dropDown a, ' +
      'div#customiseFacets > a, a.removeLink, .erk-button, .rawTaxonSumbit').tooltip();

    // maultiple facets popup - sortable column heading links
    $('a.fsort').live('click', function(e) {
        e.preventDefault();
        var fsort = $(this).data('sort');
        var foffset = $(this).data('foffset');
        var table = $(this).closest('table');
        if(table.length === 0) {
            table = $(this).parent().siblings('#fullFacets');
        }
        var facetName = $(table).data('facet');
        loadFacetsContent(facetName, fsort, foffset, BC_CONF.facetLimit, true);
    });

    // loadMoreValues (legacy - now handled by inview)
    $('.loadMoreValues').live('click', function(e) {
        var link = $(this);
        var fsort = link.data('sort');
        var foffset = link.data('foffset');
        var table = $('#fullFacets');
        var facetName = $(table).data('facet');
        loadFacetsContent(facetName, fsort, foffset, link.data('count'), false);
    });

    // Show/hide the facet groups
    $('.showHideFacetGroup').click(function(e) {
        e.preventDefault();
        var name = $(this).data('name');

        $(this).find('span').toggleClass('right-caret');

        amplify.store('search-facets-state-' + name, true);

        $('#group_' + name).slideToggle(600, function() {

            if($('#group_' + name).is(':visible')) {
                amplify.store('search-facets-state-' + name, true);
            } else {
                amplify.store('search-facets-state-' + name, null);
            }
        });
    });

    // Hide any facet groups if they don't contain any facet values
    $('.facetsGroup').each(function(i, el) {
        var name = $(el).attr('id').replace(/^group_/, '');
        var wasShown = amplify.store('search-facets-state-' + name);

        if($.trim($(el).html()) === '') {
            $('#heading_' + name).hide();
        } else if(wasShown) {
            $(el).prev().find('a').click();
        }
    });

    // scroll bars on facet values
    $('.nano').nanoScroller({ preventPageScrolling: true });

    // store last search in local storage for a "back button" on record pages
    amplify.store('lastSearch', $.url().attr('relative'));

    // Lightbox
    $(document).delegate('*[data-toggle="lightbox"]', 'click', function(event) {
        event.preventDefault();
        $(this).ekkoLightbox();
    });

    // set size of modal dialog during a resize
    // XXX This shouldn't be necessary.
    $(window).on('resize', setDialogSize);
    function setDialogSize() {
        var height = $(window).height();
        height *= 0.8;
        $('#viewerContainerId').height(height);
    }

    $('#submitDownloadMap').click(function(e) {
        e.preventDefault();
        var bounds = occMap.map.getBounds();
        var ne = bounds.getNorthEast();
        var sw = bounds.getSouthWest();
        var extents = [sw.lng, sw.lat, ne.lng, ne.lat].join(',');

        var dpi = $('#dpi').val();
        var dotRadius = $('#pradiusmm').val();

        if(dpi === '100' && parseFloat(dotRadius) < 0.3) {
            // Smaller dots won't appear on 100 dpi map
            dotRadius = '0.3';
        }

        var downloadUrl = $('#mapDownloadUrl').val() +
            BC_CONF.searchString +
            '&extents=' + extents +  // need to retrieve the
            '&format=' + $('#format').val() +
            '&dpi=' + dpi +
            '&pradiusmm=' + dotRadius +
            '&popacity=' + $('#popacity').val() +
            '&pcolour=' + $(':input[name=pcolour]').val().replace('#', '').toUpperCase() +
            '&widthmm=' + $('#widthmm').val() +
            '&scale=' + $(':input[name=scale]:checked').val() +
            '&outline=' + $(':input[name=outline]:checked').val() +
            '&outlineColour=0x000000' +
            '&baselayer=' + $('#baselayer').val() +
            '&fileName=' + $('#fileName').val() + '.' + $('#format').val().toLowerCase();

        $('#downloadMap').modal('hide');
        window.open(downloadUrl);
    });
}); // end JQuery document ready

/**
 * Catch sort drop-down and build GET URL manually
 */
function reloadWithParam(paramName, paramValue) {
    var paramList = [];
    var q = $.url().param('q'); // $.query.get('q')[0];
    var fqList = $.url().param('fq'); // $.query.get('fq');
    var sort = $.url().param('sort');
    var dir = $.url().param('dir');
    var pageSize = $.url().param('pageSize');
    var lat = $.url().param('lat');
    var lon = $.url().param('lon');
    var rad = $.url().param('radius');
    var taxa = $.url().param('taxa');

    // add query param
    if(q) {
        paramList.push('q=' + q);
    }

    // add filter query param
    if(fqList && typeof fqList === 'string') {
        fqList = [fqList];
    } else if(!fqList) {
        fqList = [];
    }

    if(fqList) {
        paramList.push('fq=' + fqList.join('&fq='));
    }

    // add sort/dir/pageSize params if already set (different to default)
    if(sort && paramName !== 'sort') {
        paramList.push('sort=' + sort);
    }

    if(dir && paramName !== 'dir') {
        paramList.push('dir=' + dir);
    }

    if(pageSize && paramName !== 'pageSize') {
        paramList.push('pageSize=' + pageSize);
    }

    if(paramName && paramValue) {
        paramList.push(paramName + '=' + paramValue);
    }

    if(lat && lon && rad) {
        paramList.push('lat=' + lat);
        paramList.push('lon=' + lon);
        paramList.push('radius=' + rad);
    }

    if(taxa) {
        paramList.push('taxa=' + taxa);
    }

    window.location.href = window.location.pathname + '?' + paramList.join('&');
}

/**
 * triggered when user removes an active facet - re-calculates the request params for
 * page minus the requested fq param
 */
function removeFacet(el) {
    var facet = $(el).data('facet').replace(/\+/g, ' ');
    var q = $.url().param('q');  // $.query.get('q')[0];
    var fqList = $.url().param('fq');  // $.query.get('fq');
    var lat = $.url().param('lat');
    var lon = $.url().param('lon');
    var rad = $.url().param('radius');
    var taxa = $.url().param('taxa');
    var paramList = [];

    if(q) {
        paramList.push('q=' + q);
    }

    // add filter query param
    if(fqList && typeof fqList === 'string') {
        fqList = [fqList];
    }

    if(lat && lon && rad) {
        paramList.push('lat=' + lat);
        paramList.push('lon=' + lon);
        paramList.push('radius=' + rad);
    }

    if(taxa) {
        paramList.push('taxa=' + taxa);
    }

    if(fqList instanceof Array) {
        for(var i in fqList) {
            var thisFq = decodeURIComponent(fqList[i].replace(/\+/g, ' '));
            if(thisFq.indexOf(decodeURIComponent(facet)) !== -1) {
                fqList.splice($.inArray(fqList[i], fqList), 1);
            }
        }
    } else {
        if(decodeURIComponent(fqList) === facet) {
            fqList = null;
        }
    }

    if(fqList) {
        paramList.push('fq=' + fqList.join('&fq='));
    }

    window.location.href = String(window.location.pathname + '?' + paramList.join('&') + window.location.hash);
}

function removeFilter(el) {
    var facet = $(el).data('facet').replace(/^\-/g, '');  // remove leading '-' for exclude searches
    var q = $.url().param('q');  // $.query.get('q')[0];
    var fqList = $.url().param('fq');  // $.query.get('fq');
    var lat = $.url().param('lat');
    var lon = $.url().param('lon');
    var rad = $.url().param('radius');
    var taxa = $.url().param('taxa');
    var wkt = $.url().param('wkt');
    var paramList = [];

    if(q) {
        paramList.push('q=' + q);
    }

    // add filter query param
    if(fqList && typeof fqList === 'string') {
        fqList = [fqList];
    }

    if(lat && lon && rad) {
        paramList.push('lat=' + lat);
        paramList.push('lon=' + lon);
        paramList.push('radius=' + rad);
    }

    if(wkt) {
        paramList.push('wkt=' + wkt);
    }

    if(taxa) {
        paramList.push('taxa=' + taxa);
    }

    for(var i in fqList) {
        var fqParts = fqList[i].split(':');
        var fqField = fqParts[0].replace(/[\(\)\-]/g, '');

        if(fqField.indexOf(facet) !== -1) {
            fqList.splice($.inArray(fqList[i], fqList), 1);
        }
    }

    if(facet === 'all') {
        fqList = [];
    }

    if(fqList) {
        paramList.push('fq=' + fqList.join('&fq='));
    }

    window.location.href = String(window.location.pathname + '?' + paramList.join('&') + window.location.hash);
}

/**
 * Load the default charts
 */
function loadDefaultCharts() {
    if(this.dynamicFacets && this.dynamicFacets.length > 0) {
        var chartsConfigUri = BC_CONF.biocacheServiceUrl + '/upload/charts/' + BC_CONF.selectedDataResource + '.json';
        $.getJSON(chartsConfigUri, function(chartsConfig) {

            var conf = {};

            $.each(chartsConfig, function(index, config) {
                if(config.visible) {
                    conf[config.field] = {
                        chartType: config.format === 'pie' ? 'doughnut' : 'bar',
                        emptyValueMsg: '',
                        hideEmptyValues: true,
                        title: config.field
                    };
                }
            });
            chartConfig.charts = conf;

            var charts = ALA.BiocacheCharts('tab-charts', chartConfig);
        });
    } else {
        var charts = ALA.BiocacheCharts('tab-charts', chartConfig);
    }
}

/**
 * Load the user charts
 */
function loadUserCharts() {

    if(userChartConfig) {  // userCharts
        // load user charts
        $.ajax({
            dataType: 'json',
            url: BC_CONF.serverName + '/user/chart',
            success: function(data) {
                if($.map(data, function(n, i) {
                    return i;
                }).length > 3) {
                    // do not display user charts by default
                    $.map(data.charts, function(value, key) {
                        value.hideOnce = true;
                    });

                    data.chartControlsCallback = saveChartConfig;

                    // set current context
                    data.biocacheServiceUrl = userChartConfig.biocacheServiceUrl;
                    data.biocacheWebappUrl = userChartConfig.biocacheWebappUrl;
                    data.query = userChartConfig.query;
                    data.queryContext = userChartConfig.queryContext;
                    data.filter = userChartConfig.filter;
                    data.facetQueries = userChartConfig.facetQueries;

                    var charts = ALA.BiocacheCharts('userCharts', data);
                } else {
                    userChartConfig.charts = {};
                    userChartConfig.chartControlsCallback = saveChartConfig;
                    var charts = ALA.BiocacheCharts('userCharts', userChartConfig);
                }
            },
            error: function(data) {
                userChartConfig.charts = {};
                userChartConfig.chartControlsCallback = saveChartConfig;
                var charts = ALA.BiocacheCharts('userCharts', userChartConfig);
            }
        })
    }
}

function saveChartConfig(data) {
    var d = $.extend(true, {}, data);

    // remove unnecessary data
    delete d.chartControlsCallback;
    $.each(d.charts, function(key, value) {
        if(value.slider) {
            delete value.slider;
        }

        if(value.datastructure) {
            delete value.datastructure;
        }

        if(value.chart) {
            delete value.chart;
        }
    });

    if(data) {
        $.ajax({
            url: BC_CONF.serverName + '/user/chart',
            type: 'POST',
            dataType: 'json',
            contentType: 'application/json',
            data: JSON.stringify(d)
        });
    }
}

/**
 * Load images in images tab
 */
function loadImagesInTab() {
    loadImages(0);
}

function loadImages(start) {
    start = (start) ? start : 0;
    var imagesJsonUri = BC_CONF.biocacheServiceUrl + '/occurrences/search.json' +
        BC_CONF.searchString +
        '&fq=multimedia:Image' +
        '&facet=false' +
        '&pageSize=20' +
        '&start=' + start +
        '&sort=identification_qualifier_s' +
        '&dir=asc' +
        '&callback=?';

    $.getJSON(imagesJsonUri, function(data) {
        if(data.occurrences) {
            if(start === 0) {
                $('#imagesGrid').html('');
            }

            var count = 0;

            $.each(data.occurrences, function(i, el) {
                count++;
                // clone template div & populate with metadata
                var $ImgConTmpl = $('.gallery-thumb-template').clone();

                $ImgConTmpl.removeClass('gallery-thumb-template').removeClass('invisible');

                var link = $ImgConTmpl.find('a.cbLink');
                link.addClass('thumbImage tooltips');
                link.attr('title', 'click to enlarge');
                link.attr('data-occurrenceuid', el.uuid);
                link.attr('data-image-id', el.largeImageUrl);
                link.attr('data-scientific-name', el.raw_scientificName);
                link.attr('data-gallery', 'main-gallery');
                link.attr('data-remote', BC_CONF.hostName + el.image.replace('/data', '/'));

                $ImgConTmpl.find('img').attr('src', el.smallImageUrl);
                // brief metadata
                var briefHtml = el.raw_scientificName;
                var br = '<br />';
                if(el.typeStatus) {
                    briefHtml += br + el.typeStatus;
                }
                if(el.institutionName) { briefHtml += ((el.typeStatus) ? ' | ' : br) + el.institutionName; }
                $ImgConTmpl.find('.gallery-thumb__footer').html(briefHtml);

                // detail metadata
                var leftDetail = '<div><b>' + $.i18n.prop('gallery.modal.taxon') + ':</b> ' + el.raw_scientificName;

                if(el.typeStatus) { leftDetail += br + '<b>' + $.i18n.prop('gallery.modal.type') + ':</b> ' + el.typeStatus; }
                if(el.collector) { leftDetail += br + '<b>' + $.i18n.prop('gallery.modal.by') + ':</b> ' + el.collector; }
                if(el.eventDate) { leftDetail += br + '<b>' + $.i18n.prop('gallery.modal.date') + ':</b> ' + moment(el.eventDate).format('YYYY-MM-DD'); }

                leftDetail += br + '<b>' + $.i18n.prop('gallery.modal.source') + ':</b> ';
                if(el.institutionName) {
                    leftDetail += el.institutionName;
                } else {
                    leftDetail += el.dataResourceName;
                }
                leftDetail += '</div>';

                var rightDetail =
                    '<div>' +
                        '<a href="' + BC_CONF.contextPath + '/occurrences/' + el.uuid + '">' +
                            $.i18n.prop('gallery.modal.viewRecord') +
                        '</a>' +
                    '</div>';

                var detailHtml = leftDetail + rightDetail;

                link.attr('data-footer', detailHtml);

                // write to DOM
                $('#imagesGrid').append($ImgConTmpl.html());
            });

            if(count + start < data.totalRecords) {
                $('#imagesGrid').data('count', count + start);
                $('#loadMoreImages').show();
                $('#loadMoreImages .erk-button').removeClass('disabled');
            } else {
                $('#loadMoreImages').hide();
            }

        }
    }).always(function() {
        $('#loadMoreImages img').hide();
    });
}

/**
 * draws the div for selecting multiple facets (popup div)
 *
 * Uses HTML template, found in the table itself.
 * See: http://stackoverflow.com/a/1091493/249327
 */
function loadMoreFacets(facetName, displayName, fsort, foffset) {
    foffset = (foffset) ? foffset : '0';
    var facetLimit = BC_CONF.facetLimit;
    var params = BC_CONF.searchString.replace(/^\?/, '').split('&');
    // include hidden inputs for current request params
    var inputsHtml = '';
    $.each(params, function(i, el) {
        var pair = el.split('=');
        if(pair.length === 2) {
            inputsHtml += '<input type="hidden" name="' + pair[0] + '" value="' + pair[1] + '" />';
        }
    });
    $('#facetRefineForm').append(inputsHtml);
    $('#fullFacets').data('facet', facetName);  // data attribute for storing facet field
    $('#fullFacets').data('label', displayName);  // data attribute for storing facet display name
    $('#indexCol a').html(displayName);  // table heading

    $('a.fsort').tooltip();

    // perform ajax
    loadFacetsContent(facetName, fsort, foffset, facetLimit);

}

function loadFacetsContent(facetName, fsort, foffset, facetLimit, replaceFacets) {
    var jsonUri = BC_CONF.biocacheServiceUrl + '/occurrences/search.json' +
        BC_CONF.searchString +
        '&facets=' + facetName +
        '&flimit=' + facetLimit +
        '&foffset=' + foffset +
        '&pageSize=0';

    if(fsort) {
        // so default facet sorting is used in initial loading
        jsonUri += '&fsort=' + fsort;
    }
    jsonUri += '&callback=?';  // JSONP trigger

    $.getJSON(jsonUri, function(data) {

        if(data.totalRecords && data.totalRecords > 0) {
            var hasMoreFacets = false;
            var html = '';
            $('tr#loadingRow').remove();  // remove the loading message
            $('tr#loadMore').remove();  // remove the load more records link
            if(replaceFacets) {
                // remove any facet values in table
                $('#fullFacets tr').not('tr.tableHead').not('#spinnerRow').remove();
            }

            $.each(data.facetResults[0].fieldResult, function(i, el) {
                if(el.count > 0) {
                    // surround with quotes: fq value if contains spaces but not for range queries
                    var fqEsc = ((el.label.indexOf(' ') !== -1 || el.label.indexOf(',') !== -1 || el.label.indexOf('lsid') !== -1) && el.label.indexOf('[') !== 0)
                        ? '"' + el.label + '"'
                        : el.label; // .replace(/:/g,"\\:")

                    var label = (el.displayLabel) ? el.displayLabel : el.label;

                    if(!label) {
                        label = $.i18n.prop('facet.absent');
                        $('tr#facets-row-absent').remove();  // remove the absent row, as it is reinserted
                    }

                    var code;
                    var encodeFq = true; // Not sure what the point of this is.

                    if(label.indexOf('@') !== -1) {
                        label = label.substring(0, label.indexOf('@'));
                    } else if(facetName.indexOf('outlier_layer') !== -1 || (/^el\d+/).test(label)) {
                        label = $.i18n.prop('layer.' + label);
                    // XXX !!! XXX
                    } else if(facetName.indexOf('geospatial_kosher') !== -1 || (/^el\d+/).test(label)) {
                        label = $.i18n.prop('geospatial_kosher.' + label);
                    } else if(facetName.indexOf('user_assertions') !== -1 || (/^el\d+/).test(label)) {
                        label = $.i18n.prop('assertions.' + label);
                    } else if(facetName.indexOf('duplicate_type') !== -1 || (/^el\d+/).test(label)) {
                        label = $.i18n.prop('duplication.' + label);
                    } else if(facetName.indexOf('taxonomic_issue') !== -1 || (/^el\d+/).test(label)) {
                        label = $.i18n.prop(label);
                    } else {
                        code = facetName + '.' + label;
                        if(code in $.i18n.map) {
                            label = $.i18n.prop(code);
                        } else if(label in $.i18n.map) {
                            label = $.i18n.prop(label);
                        }
                    }

                    facetName = facetName.replace(/_RNG$/, ''); // remove range version if present

                    var fqParam;

                    if(el.fq) {
                        fqParam = encodeURIComponent(el.fq);
                    } else if(encodeFq) {
                        fqParam = facetName + ':' + encodeURIComponent(fqEsc);
                    } else {
                        fqParam = facetName + ':' + fqEsc;
                    }

                    // NC: 2013-01-16 I changed the link so that the search string is uri encoded so that " characters do not cause issues
                    // Problematic URL http://biocache.ala.org.au/occurrences/search?q=lsid:urn:lsid:biodiversity.org.au:afd.taxon:b76f8dcf-fabd-4e48-939c-fd3cafc1887a&fq=geospatial_kosher:true&fq=state:%22Australian%20Capital%20Territory%22
                    var link = BC_CONF.searchString + '&fq=' + fqParam;

                    html +=
                        '<tr>' +
                            '<td>' +
                                '<input type="checkbox" name="fqs" class="fqs" value="' + fqParam + '" />' +
                            '</td>' +
                            '<td>' +
                            '<a href="' + link + '">' +
                                    label +
                                '</a>' +
                            '</td>' +
                            '<td style="text-align: right">' +
                                el.count +
                            '</td>' +
                        '</tr>';
                }

                if(i >= facetLimit - 1) {
                    hasMoreFacets = true;
                }
            });

            $('#fullFacets tbody').append(html);
            $('#spinnerRow').hide();
            // Fix some border issues - ToDo this only somewhat fixes...
            $('#fullFacets tr:last td').css('border-bottom', '1px solid #CCCCCC');
            $('#fullFacets td:last-child, #fullFacets th:last-child').css('border-right', 'none');

            if(hasMoreFacets) {
                var offsetInt = Number(foffset);
                var flimitInt = Number(facetLimit);
                var loadMore =
                    '<tr id="loadMore">' +
                        '<td colspan="3">' +
                            '<a ' +
                                'href="#index" ' +
                                'class="loadMoreValues erk-link-button" ' +
                                'data-sort="' + fsort + '" ' +
                                'data-foffset="' + (offsetInt + flimitInt) + '"' +
                                'data-count="100"' +
                            '>' +
                                $.i18n.prop('facet.modal.load') + ' 100 ' + $.i18n.prop('facet.modal.more') + '&hellip;' +
                            '</a>' +
                            '<br />' +
                            '<a ' +
                                'href="#index" ' +
                                'class="loadMoreValues erk-link-button" ' +
                                'data-sort="' + fsort + '" ' +
                                'data-foffset="' + (offsetInt + flimitInt) + '"' +
                                'data-count="1000"' +
                            '>' +
                                $.i18n.prop('facet.modal.load') + ' 1000 ' + $.i18n.prop('facet.modal.more') + '&hellip;' +
                            '</a>' +
                        '</td>' +
                    '</tr>';
                $('#fullFacets tbody').append(loadMore);
            }
        } else {
            $('tr#loadingRow').remove();  // remove the loading message
            $('tr#loadMore').remove();  // remove the load more records link
            $('#spinnerRow').hide();
            $('#fullFacets tbody').append(
                '<tr>' +
                    '<td></td>' +
                    '<td>' +
                        '[Error: no values returned]' +
                    '</td>' +
                    '<td></td>' +
                '</tr>');
        }
    });
}
