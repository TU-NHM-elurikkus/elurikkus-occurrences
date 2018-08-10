// We keep auto-complete selections here.
var facetsMap = {};

$(document).ready(function() {
    fillInstitutionCollectionDropdown();

    // Taxon auto-complete
    $('.facet-search').autocomplete({
        serviceUrl: BC_CONF.bieIndexUrl + '/search',
        dataType: 'jsonp',
        paramName: 'q',
        params: {
            limit: 10,
            fq: 'idxtype:TAXON'
        },

        minChars: 3,

        transformResult: function(response) {
            return {
                suggestions: response.searchResults.results.map(function(result) {
                    return {
                        data: result,
                        facetValue: result.guid,
                        value: result.nameComplete || result.name
                    };
                })
            };
        },

        formatResult: function(suggestion, currentValue) {
            var result = suggestion.value;
            var rank = suggestion.data.rank;
            var commonName = suggestion.data.commonName;

            if(suggestion.value) {
                var valueRegex = new RegExp(currentValue, 'ig');

                result = result.replace(valueRegex, '<strong>' + currentValue + '<\/strong>');
                commonName = commonName.replace(valueRegex, '<strong>' + currentValue + '<\/strong>');

                if(commonName) {
                    result = result + '; ' + commonName;
                }

                if(rank) {
                    result = result + ' <span class="text-muted">(' + $.i18n.prop('taxonomy.rank.' + rank) + ')</span>';
                }

                return result;
            } else {
                return '';
            }
        },

        onSelect: function(suggestion) {
            facetsMap[this.id] = suggestion;
        }
    });
});

function facetSearch() {
    var baseURL = BC_CONF.contextPath + '/occurrences/search';
    var commonArguments = 'sort=first_loaded_date&dir=desc#map';
    var inputs = [].slice.call(document.getElementsByClassName('js-search-input'));

    var textInputs = inputs.filter(function(input) {
        return input.dataset.queryParam === 'q';
    });

    // Facet inputs that are not taxon auto-complete inputs.
    var facetInputs = inputs.filter(function(input) {
        return input.dataset.queryParam === 'fq' && input.dataset.facetName !== 'taxon_name';
    });

    // Facet inputs that are taxon auto-complete inputs.
    var taxonFacetInputs = inputs.filter(function(input) {
        return input.dataset.queryParam === 'fq' && input.dataset.facetName === 'taxon_name';
    });

    // We currently use just one q input and query.
    var textQuery = 'q=' + (textInputs[0].value || '*:*');
    var facetArgs = facetInputs.map(function(input) {
        var facetName = input.dataset.facetName;
        var facet = facetsMap[input.id];
        var value = input.value;

        if(facetName === 'institution_collection') {
            return facetCollectionParam(value);
        } else if(facetName === 'start_date') {
            return facetDateParam();
        } else if(facetName === 'end_date') {
            // Do nothing: date handler takes care of them both when dealing with the start date.
        } else {
            return value ? encodeURIComponent(facetName + ':"' + value + '"') : null;
        }
    }).filter(function(arg) {
        return arg !== null;
    });

    var taxonFacetArgs = taxonFacetInputs.map(function(input) {
        var facet = facetsMap[input.id];

        return facet ? facetTaxonParam(facet) : null;
    }).filter(function(arg) {
        return arg !== null;
    });

    // Really? Yes, this is how they eat.
    var facetsQuery = facetArgs.length ? 'fq=' + facetArgs.join('&fq=') : '';
    var taxonFacetQuery = taxonFacetArgs.length ? 'fq=(' + taxonFacetArgs.join(' OR ') + ')' : '';
    var searchURL = [baseURL + '?' + textQuery, taxonFacetQuery, facetsQuery, commonArguments].filter(function(part) {
        return part !== '';
    }).join('&');

    window.location.assign(searchURL);
}

function clearSearchInputs() {
    var inputs = [].slice.call(document.getElementsByClassName('js-search-input'));

    // Clear input values.
    inputs.forEach(function(input) {
        input.value = '';
    });

    // Clear auto-complete values.
    Object.keys(facetsMap).forEach(function(key) {
        facetsMap[key] = null;
    });
}

function facetTaxonParam(facet) {
    var rank = facet.data.rank;
    var taxon = facet.data[rank] || facet.data.scientificName; // not sure the second half of this is necessary

    // XXX
    if(rank === 'subspecies') {
        rank = 'subspecies_name';
    }

    return encodeURIComponent(rank + ':"' + taxon + '"');
}

function facetCollectionParam(value) {
    if(value.substr(0, 2) === 'in') {
        return encodeURIComponent('institution_uid:' + value);
    } else if(value.substr(0, 2) === 'co') {
        return encodeURIComponent('collection_uid:' + value);
    } else {
        return null;
    }
}

function facetDateParam() {
    var start = document.getElementById('start-date').value;
    var end = document.getElementById('end-date').value;
    var value = '';

    if(!start && !end) {
        return null;
    }

    if(start) {
        value = '[' + start + 'T00:00:00Z TO ';
    } else {
        value = '[* TO ';
    }

    if(end) {
        value += end + 'T00:00:00Z]';
    } else {
        value += '*]';
    }

    return encodeURIComponent('occurrence_date:' + value);
}

function fillInstitutionCollectionDropdown() {
    $.ajax({
        url: BC_CONF.collectoryUrl + '/ws/lookup/institution',
        success: function(data) {
            var selectContent =
                '<option value="">' +
                    $.i18n.prop('advancedsearch.table05col01.option01.label') +
                '</option>';

            var optGroup;
            data.forEach(function(inst) {
                optGroup = '<optgroup label="' + inst.name + '">';
                optGroup +=
                    '<option value="' + inst.uid + '">' +
                        $.i18n.prop('advancedsearch.table05col01.option02.label') +
                    '</option>';

                inst.collections.forEach(function(coll) {
                    optGroup +=
                        '<option value="' + coll[0] + '">' +
                            coll[1] +
                        '</option>';
                });
                optGroup += '</optgroup>';
                selectContent += optGroup;
            });

            selectContent +=
                '<option value="*">' +
                    $.i18n.prop('advancedsearch.matchAnything') +
                '</option>';

            $('#institution_collection').empty().append(selectContent);
        }
    });
}
