var occTableHandler = {};

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
     * Calculates indexes of columns which must be hidden for the table to fit
     * into its container.
     *
     * @param {array} lesserCols - Indexes of cols that will be removed first.
     * @param {array} colWidths - Widths of all columns.
     * @param {number} maxWidth - Available width.
     * @returns {array}
     */
    this.getOverflowingColumns = function(lesserCols, colWidths, maxWidth) {
        var tableWidth = colWidths.reduce(function(a, b) {
            return a + b;
        });
        var overflowingWidth = tableWidth - maxWidth;
        var widthAccumulator = 0;
        var columns = []; // Overflowing column indexes.

        [].concat(lesserCols).reverse().forEach(function(i) {
            if(widthAccumulator < overflowingWidth) {
                widthAccumulator += colWidths[i];
                columns.push(i);
            }
        });

        return columns;
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
     * @param {array} columnsToHide - Indexes of columns that will be hidden.
     */
    this.updateColumns = function(rows, columnsToHide) {
        var self = this;

        self.arrayFromNodes(rows).forEach(function(row) {
            var cells = self.arrayFromNodes(row.children);
            var cellsToShow = cells.filter(function(cell, index) {
                return columnsToHide.indexOf(index) === -1;
            });
            var cellsToHide = cells.filter(function(cell, index) {
                return columnsToHide.indexOf(index) !== -1;
            });

            self.updateCells(cellsToShow, true)
            self.updateCells(cellsToHide, false)
        });
    }

    // The main method for updating the table to show & hide columns.
    this.updateTable = function(columnWidths) {
        var container = document.getElementById('results');
        var table = document.getElementById('search-results-table');
        var rows = table.getElementsByTagName('tr');
        var columnsToHide = this.getOverflowingColumns(
            this.lesserColIndexes,
            columnWidths,
            container.clientWidth
        );

        this.updateColumns(rows, columnsToHide);
    };

    this.initialise = function() {
        var table = document.getElementById('search-results-table');
        var rows = table.getElementsByTagName('tr');
        /**
         * We can get column widths from any of the rows, but we use the header
         * show because these cells also contain column configuration data.
         */
        var cells = this.arrayFromNodes(rows[0].children);
        // Columns we can remove when necessary.
        this.lesserColIndexes = cells.map(function(cell, index) {
            if(cell.dataset.priorityCol === "false") {
                return index;
            } else {
                return null;
            }
        }).filter(function(i) {
            return i !== null;
        });

        this.columnWidths = this.getColumnWidths(cells);

        // Makes the table visible and stretches it to use all available width.
        table.classList.add('search-results-table--ready');

        this.updateTable(this.columnWidths);
    }.bind(this);

    this.run = function() {
        // TODO Explain.
        setTimeout(this.initialise, 1000);
    }.bind(this)
}).apply(occTableHandler);

window.addEventListener('resize', occTableHandler.resizeThrottler, false);
document.addEventListener('DOMContentLoaded', occTableHandler.run);
