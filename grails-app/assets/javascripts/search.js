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
        var tab = $(e.target).attr('href').substr(1);

        amplify.store('search-tab-state', tab);
        location.hash = 'tab-' + tab;

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
        $('.nav-tabs a[href="' + location.hash.replace('tab-', '') + '"]').tab('show');
    } else if(storedSearchTab) {
        $('.nav-tabs a[href="#' + storedSearchTab + '"]').tab('show');
    } else {
        $('.nav-tabs a:first').tab('show');
    }

    // Substitute LSID strings for tacon names in facet values for species
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
        if (selectedFacets.length > 0) {
            // save facets to the user_facets cookie
            $.cookie("user_facets", selectedFacets, { expires: 7 });
            // reload page
            document.location.reload(true);
        } else {
            alert("Please select at least one filter category to display");
        }

    });

    // reset facet options to default values (clear cookie)
    $("#resetFacetOptions").click(function(e) {
        e.preventDefault();
        $.removeCookie('user_facets');
        document.location.reload(true);
    });

    // load stored prefs from cookie
    var userFacets = $.cookie("user_facets");
    if (userFacets) {
        $(":input.search-filter-checkbox__label__input").removeAttr("checked");
        var facetList = userFacets.split(",");
        for (i in facetList) {
            if (typeof facetList[i] === "string") {
                var thisFacet = facetList[i];
                //console.log("thisFacet", thisFacet);
                $(":input.search-filter-checkbox__label__input[value='"+thisFacet+"']").attr("checked","checked");
            }
        }
    } //  note removed else that did page refresh by triggering cookie update code.

    // select all and none buttons
    $("#selectNone").click(function(e) {
        e.preventDefault();
        $(":input.search-filter-checkbox__label__input").removeAttr("checked");
    });

    // XXX BLOODY HELL
    $("#selectAll").click(function(e) {
        e.preventDefault();
        $(":input.search-filter-checkbox__label__input").attr("checked", "checked");
    });

    // taxa search - show included synonyms with popup to allow user to refine to a single name
    $("span.lsid").not('.searchError, .lsid').each(function(i, el) {
        var lsid = $(this).attr("id");
        var nameString = $(this).html();
        var maxFacets = 20;
        var index = i; // keep a copy
        var queryContextParam = (BC_CONF.queryContext) ? "&qc=" + BC_CONF.queryContext : "";
        var jsonUri = BC_CONF.biocacheServiceUrl + "/occurrences/search.json?q=lsid:" + lsid + "&" + BC_CONF.facetQueries +
            "&facets=raw_taxon_name&pageSize=0&flimit=" + maxFacets + queryContextParam + "&callback=?";

        var $clone = $('#resultsReturned #template').clone();
        $clone.attr("id", ""); // remove the ID
        $clone.find(".taxaMenuContent").addClass("stopProp");
        // add unique IDs to some elements
        $clone.find("form.raw_taxon_search").attr("id", "rawTaxonSearch_" + i);
        $clone.find(":input.rawTaxonSumbit").attr("id", "rawTaxonSumbit_" + i);
        $clone.find('.refineTaxaSearch').attr("id", "refineTaxaSearch_" + i);

        $.getJSON(jsonUri, function(data) {
            // use HTML template, see http://stackoverflow.com/a/1091493/249327
            var speciesPageUri = BC_CONF.bieWebappUrl + "/species/" + lsid;
            var speciesPageLink = "<a href='" + speciesPageUri + "' title='Species page' target='BIE'>view species page</a>";
            $clone.find('a.erk-button').text(nameString).attr("href", speciesPageUri);
            $clone.find('.nameString').text(nameString);
            $clone.find('.speciesPageLink').html(speciesPageLink);

            var synListSize = 0;
            var synList1 = "";
            $.each(data.facetResults, function(k, el) {
                // console.log("el", el);
                if (el.fieldName == "raw_taxon_name") {
                    $.each(el.fieldResult, function(j, el1) {
                        synListSize++;
                        synList1 += "<input type='checkbox' name='raw_taxon_guid' id='rawTaxon_" + index + "_" + j +
                            "' class='rawTaxonCheckBox' value='" + el1.label + "'/>&nbsp;" +
                            "<a href='" + BC_CONF.contextPath + "/occurrences/search?q=raw_taxon_name:%22" + el1.label +
                            "%22'>" + el1.label + "</a> (" + el1.count + ")<br/>";
                    });
                }
            });

            if (synListSize == 0) {
                synList1 += "[no records found]";
            }

            // synList1 += "</div>";

            if (synListSize >= maxFacets) {
                synList1 += "<div><br>Only showing the first " + maxFacets + " names<br>See the \"Scientific name (unprocessed)\" section in the \"Refine results\" column on the left for a complete list</div>";
            }

            // synList += "</div>";

            $clone.find('div.rawTaxaList').html(synList1);
            $clone.removeClass("hide"); // XXX This won't work.
            // prevent BS dropdown from closing when clicking on content
            $clone.find('.stopProp').children().not('input.rawTaxonSumbit').click(function(e) {
                e.stopPropagation();
            });

            // $("#rawTaxonSearchForm").append(synList);
            // position it under the drop down
            // $("#refineTaxaSearch_"+i).position({
                // my: "right top",
                // at: "right bottom",
                // of: $(el), // or this
                // offset: "0 -1",
                // collision: "none"
            // });
            // $("#refineTaxaSearch_"+i).hide();
        });

        // format display with drop-down
        // $("span.lsid").before("<span class='plain'> which matched: </span>");
        // $(el).html("<a href='#' title='click for details about this taxon search' id='lsid_" + i + "'>" + nameString + "</a>");
        // $(el).addClass("dropDown");
        $(el).html($clone);
    });

    // form validation for raw_taxon_name popup div with checkboxes
    $(":input.rawTaxonSumbit").on("click", function(e) {
        e.preventDefault();
        var submitId = $(this).attr("id");
        var formNum = submitId.replace("rawTaxonSumbit_",""); // 1, 2, etc
        var checkedFound = false;

        $("#refineTaxaSearch_" + formNum).find(":input.rawTaxonCheckBox").each(function(i, el) {
            if ($(el).is(':checked')) {
                checkedFound = true;
                return false; // break loop
            }
        });

        if (checkedFound) {
            //$("form#rawTaxonSearchForm").submit();
            var form  = this.form
            $(form).submit();
        } else {
            alert('Please check at least one \"verbatim scientific name\" checkbox.');
        }
    });

    // load more images button
    $('#loadMoreImages .erk-button').live('click', function(e) {
        e.preventDefault();
        $(this).addClass('disabled');
        $(this).find('img').show(); // turn on spinner
        var start = $('#imagesGrid').data('count');
        loadImages(start);
    });

    // load more species images button
    $('#loadMoreSpecies').live('click', function(e) {
        e.preventDefault();
        var start = $('#speciesGallery').data('count');
        var group = $('#speciesGroup :selected').val();
        var sort = $('#speciesGallery').data('sort');
        loadSpeciesInTab(start, sort, group);
    });

    // species tab -> species group drop down
    $('#speciesGroup, #speciesGallerySort').live('change', function(e) {
        var group = $('#speciesGroup :selected').val();
        var sort = $('#speciesGallerySort :selected').val();
        loadSpeciesInTab(0, sort, group);
    });

    // add click even on each record row in results list
    $('.recordRow').click(function(e) {
        e.preventDefault();
        window.location.href = BC_CONF.contextPath + '/occurrences/' + $(this).attr('id');
    }).hover(function() {
        // mouse in
        $(this).css('cursor', 'pointer');
        $(this).css('background-color', '#FFF');
    }, function() {
        // mouse out
        $(this).css('cursor', 'default');
        $(this).css('background-color', 'transparent');
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
        var facetName = $('table#fullFacets').data('facet');
        // console.log('clicked ' + window.location.href );
        window.location.href = BC_CONF.biocacheServiceUrl + '/occurrences/facets/download' + BC_CONF.facetDownloadQuery + '&facets=' + facetName + '&count=true';
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
            fq = '(' + fq + ')'; // so that exclude (inverse) searches work
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
        var facetName = $('table#fullFacets').data('facet');
        var fqString = '&fq=' + inverseModifier + facetName + ':*';
        window.location.href = window.location.pathname + BC_CONF.searchString + fqString;
    });

    $('a.multipleFacetsLink, a#downloadLink, a#alertsLink, .tooltips, .tooltip, span.dropDown a, div#customiseFacets > a, a.removeLink, .erk-button, .rawTaxonSumbit').tooltip();

    // maultiple facets popup - sortable column heading links
    $('a.fsort').live('click', function(e) {
        e.preventDefault();
        var fsort = $(this).data('sort');
        var foffset = $(this).data('foffset');
        var table = $(this).closest('table');
        if(table.length === 0) {
            table = $(this).parent().siblings('table#fullFacets');
        }
        var facetName = $(table).data('facet');
        loadFacetsContent(facetName, fsort, foffset, BC_CONF.facetLimit, true);
    });

    // loadMoreValues (legacy - now handled by inview)
    $('a.loadMoreValues').live('click', function(e) {
        e.preventDefault();
        var link = $(this);
        var fsort = link.data('sort');
        var foffset = link.data('foffset');
        var table = $('table#fullFacets');
        var facetName = $(table).data('facet');
        loadFacetsContent(facetName, fsort, foffset, BC_CONF.facetLimit, false);
    });

    // Inview trigger to load more values when tr comes into view
    $('tr#loadMore').live('inview', function() {
        var link = $(this).find('a.loadMoreValues');
        var fsort = link.data('sort');
        var foffset = link.data('foffset');
        var table = $('table#fullFacets');
        var facetName = $(table).data('facet');
        loadFacetsContent(facetName, fsort, foffset, BC_CONF.facetLimit, false);
    });

    // Email alert buttons
    var alertsUrlPrefix = BC_CONF.alertsUrl || 'http://alerts.ala.org.au';
    $('a#alertNewRecords, a#alertNewAnnotations').click(function(e) {
        e.preventDefault();
        var query = $('<p>' + BC_CONF.queryString + '</p>').text(); // strips <span> from string
        var fqArray = decodeURIComponent(BC_CONF.facetQueries).split('&fq=').filter(function(e) { return e === 0 || e; }); // remove empty elements
        if(fqArray) {
            var fqueryString = fqArray.join('; ');
            if(fqueryString.length > 0) {
                query += ' (' + fqueryString + ')'; // append the fq queries to queryString
            }
        }
        var methodName = $(this).data('method');
        var url = alertsUrlPrefix + '/ws/' + methodName + '?';
        url += 'queryDisplayName=' + encodeURIComponent(query);
        url += '&baseUrlForWS=' + encodeURIComponent(BC_CONF.biocacheServiceUrl.replace(/\/ws$/, ''));
        url += '&baseUrlForUI=' + encodeURIComponent(BC_CONF.serverName);
        url += '&webserviceQuery=%2Fws%2Foccurrences%2Fsearch' + BC_CONF.searchString;
        url += '&uiQuery=%2Foccurrences%2Fsearch%3Fq%3D*%3A*';
        url += '&resourceName=' + encodeURIComponent(BC_CONF.resourceName);
        window.location.href = url;
    });

    /**
     * Load Spring i18n messages into JS
     */
    jQuery.i18n.properties({
        name: 'messages',
        path: BC_CONF.contextPath + '/messages/i18n/',
        mode: 'map',
        language: BC_CONF.locale // default is to use browser specified locale
        //callback: function(){} //alert( "facet.conservationStatus = " + jQuery.i18n.prop('facet.conservationStatus')); }
    });

    // Show/hide the facet groups
    $('.showHideFacetGroup').click(function(e) {
        e.preventDefault();
        var name = $(this).data('name');

        // console.log('search-facets-state-' + name + '=')

        $(this).find('span').toggleClass('right-caret');

        // NEW TODO
        amplify.store('search-facets-state-' + name, true);

        $('#group_' + name).slideToggle(600, function() {
            // console.log('showHideFacetGroup', name);

            if($('#group_' + name).is(":visible")) {
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
            // console.log("wasShown", $(el).prev());
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
    $(window).on('resize', setDialogSize)
    function setDialogSize() {
        var height = $(window).height()
        height *= 0.8
        $("#viewerContainerId").height(height);
    }
}); // end JQuery document ready

/**
 * Catch sort drop-down and build GET URL manually
 */
function reloadWithParam(paramName, paramValue) {
    var paramList = [];
    var q = $.url().param('q'); //$.query.get('q')[0];
    var fqList = $.url().param('fq'); //$.query.get('fq');
    var sort = $.url().param('sort');
    var dir = $.url().param('dir');
    var pageSize = $.url().param('pageSize');
    var lat = $.url().param('lat');
    var lon = $.url().param('lon');
    var rad = $.url().param('radius');
    var taxa = $.url().param('taxa');
    // add query param
    if (q != null) {
        paramList.push("q=" + q);
    }
    // add filter query param
    if (fqList && typeof fqList === "string") {
        fqList = [ fqList ];
    } else if (!fqList) {
        fqList = [];
    }

    if (fqList) {
        paramList.push("fq=" + fqList.join("&fq="));
    }

    // add sort/dir/pageSize params if already set (different to default)
    if (paramName != 'sort' && sort != null) {
        paramList.push('sort' + "=" + sort);
    }

    if (paramName != 'dir' && dir != null) {
        paramList.push('dir' + "=" + dir);
    }

    if (paramName != 'pageSize' && pageSize != null) {
        paramList.push("pageSize=" + pageSize);
    }

    if (paramName != null && paramValue != null) {
        paramList.push(paramName + "=" +paramValue);
    }

    if (lat && lon && rad) {
        paramList.push("lat=" + lat);
        paramList.push("lon=" + lon);
        paramList.push("radius=" + rad);
    }

    if (taxa) {
        paramList.push("taxa=" + taxa);
    }

    //alert("params = "+paramList.join("&"));
    //alert("url = "+window.location.pathname);
    window.location.href = window.location.pathname + '?' + paramList.join('&');
}

/**
 * triggered when user removes an active facet - re-calculates the request params for
 * page minus the requested fq param
 */
function removeFacet(el) {
    var facet = $(el).data("facet").replace(/\+/g,' ');
    var q = $.url().param('q'); //$.query.get('q')[0];
    var fqList = $.url().param('fq'); //$.query.get('fq');
    var lat = $.url().param('lat');
    var lon = $.url().param('lon');
    var rad = $.url().param('radius');
    var taxa = $.url().param('taxa');
    var paramList = [];
    if (q != null) {
        paramList.push("q=" + q);
    }
    // console.log("0. fqList", fqList);
    // add filter query param
    if (fqList && typeof fqList === "string") {
        fqList = [ fqList ];
    }

    //console.log("1. fqList", fqList);

    if (lat && lon && rad) {
        paramList.push("lat=" + lat);
        paramList.push("lon=" + lon);
        paramList.push("radius=" + rad);
    }

    if (taxa) {
        paramList.push("taxa=" + taxa);
    }

    //alert("this.facet = "+facet+"; fqList = "+fqList.join('|'));

    if (fqList instanceof Array) {
        //alert("fqList is an array");
        for (var i in fqList) {
            var thisFq = decodeURIComponent(fqList[i].replace(/\+/g,' ')); //.replace(':[',':'); // for dates to work
            //alert("fq = "+thisFq + " || facet = "+decodeURIComponent(facet));
            if (thisFq.indexOf(decodeURIComponent(facet)) != -1) {  // if(str1.indexOf(str2) != -1){
                //alert("removing fq: "+fqList[i]);
                fqList.splice($.inArray(fqList[i], fqList), 1);
            }
        }
    } else {
        //alert("fqList is NOT an array");
        if (decodeURIComponent(fqList) == facet) {
            fqList = null;
        }
    }
    //alert("(post) fqList = "+fqList.join('|'));
    if (fqList != null) {
        paramList.push("fq=" + fqList.join("&fq="));
    }

    window.location.href = window.location.pathname + '?' + paramList.join('&') + window.location.hash +"";
}

function removeFilter(el) {
    var facet = $(el).data("facet").replace(/^\-/g,''); // remove leading "-" for exclude searches
    var q = $.url().param('q'); //$.query.get('q')[0];
    var fqList = $.url().param('fq'); //$.query.get('fq');
    var lat = $.url().param('lat');
    var lon = $.url().param('lon');
    var rad = $.url().param('radius');
    var taxa = $.url().param('taxa');
    var wkt = $.url().param('wkt');
    var paramList = [];
    if (q != null) {
        paramList.push("q=" + q);
    }

    // add filter query param
    if (fqList && typeof fqList === "string") {
        fqList = [ fqList ];
    }

    if (lat && lon && rad) {
        paramList.push("lat=" + lat);
        paramList.push("lon=" + lon);
        paramList.push("radius=" + rad);
    }

    if (wkt) {
        paramList.push("wkt=" + wkt);
    }

    if (taxa) {
        paramList.push("taxa=" + taxa);
    }

    for (var i in fqList) {
        var fqParts = fqList[i].split(':');
        var fqField = fqParts[0].replace(/[\(\)\-]/g, "");

        if (fqField.indexOf(facet) != -1) {  // if(str1.indexOf(str2) != -1){
            fqList.splice($.inArray(fqList[i], fqList), 1);
        }
    }

    if (facet == "all") {
        fqList = [];
    }

    if (fqList != null) {
        paramList.push("fq=" + fqList.join("&fq="));
    }

    window.location.href = window.location.pathname + '?' + paramList.join('&') + window.location.hash +"";
}

/**
 * Load the default charts
 */
function loadDefaultCharts() {
    if (this.dynamicFacets && this.dynamicFacets.length > 0) {
        var chartsConfigUri = BC_CONF.biocacheServiceUrl + "/upload/charts/" + BC_CONF.selectedDataResource + ".json";
        $.getJSON(chartsConfigUri, function (chartsConfig) {

            console.log("Number of dynamic charts to render: " + chartsConfig.length, dynamicFacets);

            var conf = {}

            $.each(chartsConfig, function (index, config) {
                if (config.visible) {
                    var type = 'bar'
                    if (config.format == 'pie') type = 'doughnut'
                    conf[config.field] = {
                        chartType: type,
                        emptyValueMsg: '',
                        hideEmptyValues: true,
                        title: config.field
                    }
                }
            });
            chartConfig.charts = conf;

            var charts = ALA.BiocacheCharts('charts', chartConfig);
        });
    } else {
        var charts = ALA.BiocacheCharts('charts', chartConfig);
    }
}

/**
 * Load the user charts
 */
function loadUserCharts() {

    if (userChartConfig) { //userCharts
        //load user charts
        $.ajax({
            dataType: "json",
            url: BC_CONF.serverName + "/user/chart",
            success: function(data) {
                if ($.map(data, function (n, i) {
                        return i;
                    }).length > 3) {
                    // console.log("loading user chart data")
                    // console.log(data)

                    //do not display user charts by default
                    $.map(data.charts, function (value, key) {
                        value.hideOnce = true;
                    });

                    data.chartControlsCallback = saveChartConfig

                    //set current context
                    data.biocacheServiceUrl = userChartConfig.biocacheServiceUrl;
                    data.biocacheWebappUrl = userChartConfig.biocacheWebappUrl;
                    data.query = userChartConfig.query;
                    data.queryContext = userChartConfig.queryContext;
                    data.filter = userChartConfig.filter;
                    data.facetQueries = userChartConfig.facetQueries;

                    var charts = ALA.BiocacheCharts('userCharts', data);
                } else {
                    userChartConfig.charts = {}
                    userChartConfig.chartControlsCallback = saveChartConfig
                    var charts = ALA.BiocacheCharts('userCharts', userChartConfig);
                }
            },
            error: function (data) {
                userChartConfig.charts = {}
                userChartConfig.chartControlsCallback = saveChartConfig
                var charts = ALA.BiocacheCharts('userCharts', userChartConfig);
            }
        })
    }
}

function saveChartConfig(data) {
    // console.log("saving user chart data");
    // console.log(data);

    var d = jQuery.extend(true, {}, data);

    //remove unnecessary data
    delete d.chartControlsCallback
    $.each (d.charts, function(key, value) { if (value.slider) delete value.slider; });
    $.each (d.charts, function(key, value) { if (value.datastructure) delete value.datastructure});
    $.each (d.charts, function(key, value) { if (value.chart) delete value.chart});

    if (data) {
        $.ajax({
            url: BC_CONF.serverName + "/user/chart",
            type: "POST",
            dataType: 'json',
            contentType: 'application/json',
            data: JSON.stringify(d)
        })
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
        '&fq=multimedia:Image&facet=false&pageSize=20&start=' + start +
        '&sort=identification_qualifier_s&dir=asc&callback=?';

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
                var leftDetail = '<div class="col-sm-10"><b>Taxon:</b> ' + el.raw_scientificName;
                if(el.typeStatus) { leftDetail += br + '<b>Type:</b> ' + el.typeStatus; }
                if(el.collector) { leftDetail += br + '<b>By:</b> ' + el.collector; }
                if(el.eventDate) { leftDetail += br + '<b>Date:</b> ' + moment(el.eventDate).format('YYYY-MM-DD'); }

                leftDetail += br + '<b>Source:</b> ';
                if(el.institutionName) {
                    leftDetail += el.institutionName;
                } else {
                    leftDetail += el.dataResourceName;
                }
                leftDetail += '</div>';

                var rightDetail =
                    '<div class="col-sm-2" style="text-align:right;">' +
                        '<a href="' + BC_CONF.contextPath + '/occurrences/' + el.uuid + '">' +
                            'View record' +
                        '</a>' +
                    '</div>';

                var detailHtml = '<div class="row">' + leftDetail + rightDetail + '</div>';

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
 * Load the species tab with list of species from the current query.
 * Uses automatic scrolling to load new bunch of rows when user scrolls.
 *
 * @param start
 */
function loadSpeciesInTab(start, sortField, group) {
    var pageSize = 20;
    var init = $('#speciesGallery').data('init');
    start = (start) ? start : 0;
    group = (group) ? group : "ALL_SPECIES";
    // sortField should be one of: taxa, common, count
    var sortExtras;
    switch (sortField) {
        case 'taxa': sortExtras = "&common=false&sort=index";
            break;
        default:
        case 'common': sortExtras = "&common=true&sort=index";
            break;
        case 'count': sortExtras = "&common=false&sort=count";
            break;
    }

    if (!init) {
        // populate the groups dropdown
        var groupsUrl = BC_CONF.biocacheServiceUrl + "/explore/groups.json" + BC_CONF.searchString + "&facets=species_group&callback=?";
        $.getJSON(groupsUrl, function(data) {
            if (data.length > 0) {
                $("#speciesGroup").empty();
                $.each(data, function(i, el) {
                    if (el.count > 0) {
                        var indent = Array(el.level + 1).join("-") + " ";
                        var dispayName = el.name.replace("_", " ");
                        if (el.level == 0) {
                            dispayName = dispayName.toLowerCase(); // lowercase
                            dispayName = dispayName.charAt(0).toUpperCase() + dispayName.slice(1); // capitalise first letter
                        }
                        var opt = $("<option value='" + el.name + "'>" + indent + dispayName + " (" + el.speciesCount + ")</option>");
                        $("#speciesGroup").append(opt);
                    }
                });
            }
        }).error(function(){ $("#speciesGroup option").val("Error: species groups were not loaded");});
        //
        $('#speciesGallery').data('init', true);
    } else {
        //$("#loadMoreSpecies").hide();
    }

    if (start == 0) {
        $("#speciesGallery").empty().before("<div id='loadingSpecies'>Loading... <img src='" + BC_CONF.contextPath + "/assets/spinner.gif'/></div>");
        $("#loadMoreSpecies").hide();
    } else {
        $("#loadMoreSpecies img").show();
    }

    var speciesJsonUrl = BC_CONF.contextPath + "/proxy/exploreGroupWithGallery" + BC_CONF.searchString + // TODO fix proxy
            "&group=" + group + "&pageSize=" + pageSize + "&start=" + start + sortExtras;

    $.getJSON(speciesJsonUrl, function(data) {
        //console.log("data", data);
        if (data.length > 0) {
            //var html = "<table><thead><tr><th>Image</th><th>Scientific name</th><th>Common name</th><th>Record count</th></tr></thead><tbody>";
            var count = 0;
            $.each(data, function(i, el) {
                // don't show higher taxa
                count++;
                if (el.rankId > 6000 && el.thumbnailUrl) {
                    var imgEl = $("<img src='" + el.thumbnailUrl +
                        "' style='height:100px; cursor:pointer;'/>");
                    var metaData = {
                        type: 'species',
                        guid: el.guid,
                        rank: el.rank,
                        rankId: el.rankId,
                        sciName: el.scientificName,
                        commonName: el.commonName,
                        count: el.count
                    };
                    imgEl.data(metaData);
                    $("#speciesGallery").append(imgEl);
                }
            });

            if (count == pageSize) {
                //console.log("load more", count, start, count + start, data.totalRecords);
                $('#speciesGallery').data('count', count + start);
                $("#loadMoreSpecies").show();
            } else {
                $("#loadMoreSpecies").hide();
            }

            $('#speciesGallery img').ibox(); // enable hover effect

            //html += "</tbody></table>";
//            $("#speciesGallery").append(html);

        }
    }).error(function (request, status, error) {
            alert(request.responseText);
    }).complete(function() {
            $("#loadingSpecies").remove();
            $("#loadMoreSpecies img").hide();
    });
}

/**
 * iBox Jquery plugin for Google Images hover effect.
 * Origin by roxon http://stackoverflow.com/users/383904/roxon
 * Posted to stack overflow:
 *   http://stackoverflow.com/questions/7411393/pop-images-like-google-images/7412302#7412302
 */
(function($) {
    $.fn.ibox = function() {
        // set zoom ratio //
        resize = 50; // pixels to add to img height
        ////////////////////
        var img = this;
        img.parent().parent().parent().append('<div id="ibox" />');
        $('body').append('<div id="ibox" />');
        var ibox = $('#ibox');
        var elX = 0;
        var elY = 0;

        img.each(function() {
            var el = $(this);

            el.mouseenter(function() {
                ibox.html('');
                var elH = el.height();
                var elW = el.width();
                var ratio = elW / elH; //(elW > elH) ? elW / elH : elH / elW;
                var newH = elH + resize;
                var newW = newH * ratio;
                var offset = (((newW - elW) / 2) + 6);
                //console.log(ratio, elW, newW, offset);
                elX = el.position().left - offset ; // 6 = CSS#ibox padding+border
                elY = el.position().top - 6;
                var h = el.height();
                var w = el.width();
                var wh;
                checkwh = (h < w) ? (wh = (w / h * resize) / 2) : (wh = (w * resize / h) / 2);

                $(this).clone().prependTo(ibox);

                var link, rank, linkTitle, count;
                var md = $(el).data();

                if (md.type == 'species') {
                    link = BC_CONF.bieWebappUrl + "/species/"  + md.guid;
                    linkTitle = "Go to ALA species page";
                    rank = " ";
                    count = " <br/>Record count: " + md.count;
                } else {
                    link = BC_CONF.contextPath + "/occurrences/"  + md.uuid;
                    linkTitle = "Go to occurrence record";
                    rank = "<span style='text-transform: capitalize'>" + md.rank + "</span>: ";
                    count = "";
                }

                var itals = (md.rankId >= 6000) ? "<span style='font-style: italic;'>" : "<span>";
                var infoDiv = "<div style=''><a href='" + link + "' title='" + linkTitle + "'>" + rank + itals +
                    md.sciName + "</span><br/>" + md.commonName.replace("| ", "") + "</a> " + count + "</div>";
                $(ibox).append(infoDiv);
                $(ibox).click(function(e) {
                    e.preventDefault();
                    window.location.href = link;
                });

                ibox.css({
                    top: elY + 'px',
                    left: elX + 'px',
                    "max-width": $(el).width() + (2 * wh) + 12
                });

                ibox.stop().fadeTo(200, 1, function() {
                    //$(this).animate({top: '-='+(resize/2), left:'-='+wh},200).children('img').animate({height:'+='+resize},200);
                    $(this).children('img').animate({height:'+='+resize},200);
                });

            });

            ibox.mouseleave(function() {
                ibox.html('').hide();
            });
        });
    };
})(jQuery);

/**
 * draws the div for selecting multiple facets (popup div)
 *
 * Uses HTML template, found in the table itself.
 * See: http://stackoverflow.com/a/1091493/249327
 */
function loadMoreFacets(facetName, displayName, fsort, foffset) {
    foffset = (foffset) ? foffset : "0";
    var facetLimit = BC_CONF.facetLimit;
    var params = BC_CONF.searchString.replace(/^\?/, "").split("&");
    // include hidden inputs for current request params
    var inputsHtml = "";
    $.each(params, function(i, el) {
        var pair = el.split("=");
        if (pair.length == 2) {
            inputsHtml += "<input type='hidden' name='" + pair[0] + "' value='" + pair[1] + "'/>";
        }
    });
    $('#facetRefineForm').append(inputsHtml);
    $('table#fullFacets').data('facet', facetName); // data attribute for storing facet field
    $('table#fullFacets').data('label', displayName); // data attribute for storing facet display name
    $('#indexCol a').html(displayName); // table heading
    // $('#indexCol a').attr('oldtitle', 'sort by ' + displayName); // table heading

    $("a.fsort").tooltip();

    // perform ajax
    loadFacetsContent(facetName, fsort, foffset, facetLimit);

}

function loadFacetsContent(facetName, fsort, foffset, facetLimit, replaceFacets) {
    var jsonUri = BC_CONF.biocacheServiceUrl + "/occurrences/search.json" + BC_CONF.searchString +
        "&facets=" + facetName + "&flimit=" + facetLimit + "&foffset=" + foffset + "&pageSize=0"; // + "&fsort=" + fsort

    if (fsort) {
        // so default facet sorting is used in initial loading
        jsonUri += "&fsort=" + fsort;
    }
    jsonUri += "&callback=?"; // JSONP trigger

    $.getJSON(jsonUri, function(data) {
        //console.log("data",data);
        if (data.totalRecords && data.totalRecords > 0) {
            var hasMoreFacets = false;
            var html = "";
            $("tr#loadingRow").remove(); // remove the loading message
            $("tr#loadMore").remove(); // remove the load more records link
            if (replaceFacets) {
                // remove any facet values in table
                $("table#fullFacets tr").not("tr.tableHead").not("#spinnerRow").remove();
            }
            // ToDo this table generatiing should be moved to groovy file where uniform translations can be applied
            $.each(data.facetResults[0].fieldResult, function(i, el) {
                if (el.count > 0) {
                    // surround with quotes: fq value if contains spaces but not for range queries
                    var fqEsc = ((el.label.indexOf(" ") != -1 || el.label.indexOf(",") != -1 || el.label.indexOf("lsid") != -1) && el.label.indexOf("[") != 0)
                        ? "\"" + el.label + "\""
                        : el.label; // .replace(/:/g,"\\:")
                    var label = (el.displayLabel) ? el.displayLabel : el.label;
                    var trIdAttr = '';
                    if (!label) {
                        label = 'absent';
                        $("tr#facets-row-absent").remove();  // remove the absent row, as it is reinserted
                        var trIdAttr = 'id=facets-row-absent'  // not proud of it, but has to do now
                    }
                    var encodeFq = true;
                    if (label.indexOf("@") != -1) {
                        label = label.substring(0,label.indexOf("@"));
                    } else if (jQuery.i18n.prop(label).indexOf("[") == -1) {
                        // i18n substitution
                        var code = facetName + "." + label;
                        var i18nLabel = jQuery.i18n.prop(code);
                        label = (i18nLabel.indexOf("[") == -1) ? i18nLabel : jQuery.i18n.prop(label);
                    } else if (facetName.indexOf("outlier_layer") != -1 || /^el\d+/.test(label)) {
                        label = jQuery.i18n.prop("layer." + label);
                    } else if (facetName.indexOf("geospatial_kosher") != -1 || /^el\d+/.test(label)) {
                        label = jQuery.i18n.prop("geospatial_kosher." + label);
                    } else if (facetName.indexOf("user_assertions") != -1 || /^el\d+/.test(label)) {
                        label = jQuery.i18n.prop("user_assertions." + label);
                    } else if (facetName.indexOf("duplicate_type") != -1 || /^el\d+/.test(label)) {
                        label = jQuery.i18n.prop("duplication." + label);
                    } else if (facetName.indexOf("taxonomic_issue") != -1 || /^el\d+/.test(label)) {
                        label = jQuery.i18n.prop(label);
                    } else {
                        var code = facetName + "." + label;
                        var i18nLabel = jQuery.i18n.prop(code);
                        var newLabel = (i18nLabel.indexOf("[") == -1) ? i18nLabel : (jQuery.i18n.prop(label));
                        label = (newLabel.indexOf("[") == -1) ? newLabel : label;
                    }
                    facetName = facetName.replace(/_RNG$/,""); // remove range version if present
                    var fqParam = (el.fq) ? encodeURIComponent(el.fq) : facetName + ":" + ((encodeFq) ? encodeURIComponent(fqEsc) : fqEsc) ;

                    //NC: 2013-01-16 I changed the link so that the search string is uri encoded so that " characters do not cause issues
                    //Problematic URL http://biocache.ala.org.au/occurrences/search?q=lsid:urn:lsid:biodiversity.org.au:afd.taxon:b76f8dcf-fabd-4e48-939c-fd3cafc1887a&fq=geospatial_kosher:true&fq=state:%22Australian%20Capital%20Territory%22
                    var link = BC_CONF.searchString + "&fq=" + fqParam;
                    // ToDo: remove this outcommented line when it's certain that normalRow/alternateRow was some deprecated hack
                    // var rowType = (i % 2 == 0) ? "normalRow" : "alternateRow";
                    html += "<tr><td>" +
                        "<input type='checkbox' name='fqs' class='fqs' value='"  + fqParam +
                        "'/></td><td><a href=\"" + link + "\"> " + label + "</a></td><td style='text-align: right'>" + el.count + "</td></tr>";
                }
                if (i >= facetLimit - 1) {
                    hasMoreFacets = true;
                }
            });
            $("table#fullFacets tbody").append(html);
            $('#spinnerRow').hide();
            // Fix some border issues - ToDo this only somewhat fixes...
            $("table#fullFacets tr:last td").css("border-bottom", "1px solid #CCCCCC");
            $("table#fullFacets td:last-child, table#fullFacets th:last-child").css("border-right", "none");
            //$("tr.hidden").fadeIn('slow');

            if (hasMoreFacets) {
                var offsetInt = Number(foffset);
                var flimitInt = Number(facetLimit);
                var loadMore = "<tr id='loadMore' class=''><td colspan='3'><a href='#index' class='loadMoreValues' data-sort='" +
                    fsort + "' data-foffset='" + (offsetInt + flimitInt) +
                    "'>Loading " + facetLimit + " more values...</a></td></tr>";
                $("table#fullFacets tbody").append(loadMore);
                //$("tr#loadMore").fadeIn('slow');
            }

            var tableHeight = $("#fullFacets tbody").height();
            var tbodyHeight = 0;
            $("#fullFacets tbody tr").each(function(i, el) {
                tbodyHeight += $(el).height();
            });
            //console.log("table heights", tableHeight, tbodyHeight);
            if (false && tbodyHeight < tableHeight) {
                // no scroll bar so adjust column widths
                var thWidth = $(".scrollContent td + td + td").width() + 18; //$("th#indexCol").width() + 36;
                $(".scrollContent td + td + td").width(thWidth);

            }
            //$.fancybox.resize();
        } else {
            $("tr#loadingRow").remove(); // remove the loading message
            $("tr#loadMore").remove(); // remove the load more records link
            $('#spinnerRow').hide();
            $("table#fullFacets tbody").append("<tr><td></td><td>[Error: no values returned]</td></tr>");
        }
    });
}
