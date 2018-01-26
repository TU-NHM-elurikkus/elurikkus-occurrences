var occurrencesTableHandler = {};

(function() {
    this.resizeThrottler = function() {
        var self = this;

        if(!self.resizeTimeout) {
            self.resizeTimeout = setTimeout(function() {
                self.resizeTimeout = null;
                self.updateTable(self.columnWidths);
            }, 333);
        }
    }.bind(this);

    /**
     * Converts HTMLCollection or NodeList to array.
     *
     * @param {HTMLCollection|NodeList} nodes - Array-like list of nodes.
     * @returns {array}
     */
    this.arrayFromNodes = function(nodes) {
        return Array.prototype.slice.call(nodes);
    };

    /**
     * Calculates table width from column widths, regardless of how many of
     * them are visible and thus not depending on actual table width.
     *
     * @param {HTMLCollection|NodeList} cells - Cells of a table row, any row.
     * @returns {array} - Array of cell widths in pixels.
     */
    this.getColumnWidths = function(cells) {
        return this.arrayFromNodes(cells).map(function(cell, index) {
            return cell.clientWidth;
        });
    };

    /**
     * Calculates the number of columns which can visibly fit into available
     * width.
     *
     * @param {array} colWidths - Array of all column widths.
     * @param {number} width - Available width in pixels.
     * @returns {number} - Count of columns that can be set visible.
     */
    this.countFittingColumns = function(colWidths, maxWidth) {
        var width = 0;
        // Unless we'll learn otherwise, we can show all columns.
        var columnsCount = colWidths.length;

        for(var i = 0; i < colWidths.length; i++) {
            width += colWidths[i];

            if(width >= maxWidth) {
                columnsCount = i;

                break;
            } else {
                continue;
            }
        }

        return columnsCount;
    };

    /**
     * Updates the visibility of cells.
     *
     * @param {HTMLCollection|NodeList} cells - Cells of a table row.
     * @param {boolean} hide.
     */
    this.updateCells = function(cells, show) {
        this.arrayFromNodes(cells).forEach(function(cell) {
            if(show) {
                cell.classList.remove('search-results-cell--hidden');
            } else {
                cell.classList.add('search-results-cell--hidden');
            }
        });
    };

    /**
     * Update visibility of table columns. Iterates over rows.
     *
     * @param {HTMLCollection|NodeList} rows - Table rows.
     * @param {number} columnsToShow.
     */
    this.updateColumns = function(rows, columnsToShow) {
        var self = this;

        // Temporary solution till prioritisation is done.
        if(columnsToShow > 1) {
            self.arrayFromNodes(rows).forEach(function(row) {
                var cells = self.arrayFromNodes(row.children);
                var cellsToShow = cells.slice(0, columnsToShow);
                var cellsToHide = cells.slice(columnsToShow);

                self.updateCells(cellsToShow, true)
                self.updateCells(cellsToHide, false)
            });
        }
    }.bind(this);

    // The main method for updating the table to show & hide columns.
    this.updateTable = function(columnWidths) {
        var container = document.getElementById('results');
        var table = document.getElementById('search-results-table');
        var rows = table.getElementsByTagName('tr');
        var columnsToShow = this.countFittingColumns(this.columnWidths,
            container.clientWidth);

        this.updateColumns(rows, columnsToShow);
    };

    this.initialise = function() {
        var table = document.getElementById('search-results-table');
        var rows = table.getElementsByTagName('tr');
        /**
         * We can get column widths from any of the rows, so the first one will
         * do just fine.
         */
        var cells = this.arrayFromNodes(rows[0].children);

        this.columnWidths = this.getColumnWidths(cells);
        this.tableWidth = this.columnWidths.reduce(
            function(accumulatedValue, currentValue) {
                return accumulatedValue + currentValue;
            }
        );

        // TODO Explain.
        table.classList.add('search-results-table--stretch');

        this.updateTable(this.columnsWidths);
    }.bind(this);

    this.run = function() {
        // TODO Explain.
        setTimeout(this.initialise, 1000);
    }.bind(this)
}).apply(occurrencesTableHandler);

window.addEventListener('resize', occurrencesTableHandler.resizeThrottler, false);
document.addEventListener('DOMContentLoaded', occurrencesTableHandler.run);
