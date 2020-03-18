(function() {
  var callWithJQuery, openImageUrl;

  callWithJQuery = function(pivotModule) {
    if (typeof exports === "object" && typeof module === "object") {
      return pivotModule(require("jquery"));
    } else if (typeof define === "function" && define.amd) {
      return define(["jquery"], pivotModule);
    } else {
      return pivotModule(jQuery);
    }
  };

  openImageUrl = function(url) {
    var iframe, x;
    iframe = "<iframe src='" + url + "'  style=\"border:0; top:0; left:0; bottom:0; right:0; width:100%; height:100%;\" allowfullscreen></iframe>";
    x = window.open();
    x.document.open();
    x.document.write(iframe);
    return x.document.close();
  };

  callWithJQuery(function($) {
    var makeGoogleChart, rendererTrans;
    makeGoogleChart = function(chartType, extraOptions) {
      return function(pivotData, opts) {
        var agg, base, chartHolder, colKey, colKeys, commonTextStyle, dataArray, dataTable, defaults, dh, fullAggName, groupByTitle, h, hAxisTitle, headers, i, imageLink, j, k, len, len1, len2, len3, maxCharsInLegend, numCharsInHAxis, options, ref, result, row, rowKey, rowKeys, title, tree2, vAxisTitle, val, wrapper, x, y;
        defaults = {
          localeStrings: {
            vs: "vs",
            by: "by",
            and: "and",
            openAsImage: "As image"
          },
          gchart: {}
        };
        opts = $.extend(true, defaults, opts);
        if ((base = opts.gchart).width == null) {
          base.width = window.innerWidth / 1.4;
        }
        rowKeys = pivotData.getRowKeys();
        if (rowKeys.length === 0) {
          rowKeys.push([]);
        }
        colKeys = pivotData.getColKeys();
        if (colKeys.length === 0) {
          colKeys.push([]);
        }
        fullAggName = $.pivotUtilities.locales[opts.lang].aggregatorTrans[pivotData.aggregatorName];
        if (pivotData.valAttrs.length) {
          fullAggName += "(" + (pivotData.valAttrs.join(", ")) + ")";
        }
        headers = (function() {
          var i, len1, results;
          results = [];
          for (i = 0, len1 = rowKeys.length; i < len1; i++) {
            h = rowKeys[i];
            results.push($.pivotUtilities.getValueTranslation(h, opts.localeStrings).join("-"));
          }
          return results;
        })();
        headers.unshift("");
        numCharsInHAxis = 0;
        if (chartType === "ScatterChart") {
          dataArray = [];
          ref = pivotData.tree;
          for (y in ref) {
            tree2 = ref[y];
            for (x in tree2) {
              agg = tree2[x];
              dataArray.push([parseFloat(x), parseFloat(y), fullAggName + ": \n" + agg.format(agg.value())]);
            }
          }
          dataTable = new google.visualization.DataTable();
          hAxisTitle = $.pivotUtilities.getTranslation(pivotData.colAttrs, opts.dataTrans).join("-");
          vAxisTitle = $.pivotUtilities.getTranslation(pivotData.rowAttrs, opts.dataTrans).join("-");
          dataTable.addColumn('number', hAxisTitle);
          dataTable.addColumn('number', vAxisTitle);
          dataTable.addColumn({
            type: "string",
            role: "tooltip"
          });
          dataTable.addRows(dataArray);
          title = "";
        } else {
          dataArray = [headers];
          for (i = 0, len1 = colKeys.length; i < len1; i++) {
            colKey = colKeys[i];
            row = [$.pivotUtilities.getValueTranslation(colKey, opts.localeStrings).join("-")];
            numCharsInHAxis += row[0].length;
            for (j = 0, len2 = rowKeys.length; j < len2; j++) {
              rowKey = rowKeys[j];
              agg = pivotData.getAggregator(rowKey, colKey);
              if (agg.value() != null) {
                val = agg.value();
                if ($.isNumeric(val)) {
                  if (val < 1) {
                    row.push(parseFloat(val.toPrecision(3)));
                  } else {
                    row.push(parseFloat(val.toFixed(3)));
                  }
                } else {
                  row.push(val);
                }
              } else {
                row.push(null);
              }
            }
            dataArray.push(row);
          }
          maxCharsInLegend = 0;
          for (k = 0, len3 = rowKeys.length; k < len3; k++) {
            rowKey = rowKeys[k];
            len = rowKey.join("-").length;
            if (maxCharsInLegend < len) {
              maxCharsInLegend = len;
            }
          }
          dataTable = google.visualization.arrayToDataTable(dataArray);
          title = vAxisTitle = fullAggName;
          hAxisTitle = $.pivotUtilities.getTranslation(pivotData.colAttrs, opts.dataTrans).join("-");
          groupByTitle = $.pivotUtilities.getTranslation(pivotData.rowAttrs, opts.dataTrans).join("-");
          if (hAxisTitle !== "" || groupByTitle !== "") {
            title += " " + opts.localeStrings.by;
            if (hAxisTitle !== "") {
              title += " " + hAxisTitle;
            }
            if (hAxisTitle !== "" && groupByTitle !== "") {
              title += " " + opts.localeStrings.and;
            }
            if (groupByTitle !== "") {
              title += " " + groupByTitle;
            }
          }
        }
        commonTextStyle = {
          fontSize: 13
        };
        options = {
          title: title,
          hAxis: {
            title: hAxisTitle,
            slantedText: numCharsInHAxis > 50,
            textStyle: commonTextStyle,
            titleTextStyle: commonTextStyle
          },
          vAxis: {
            title: vAxisTitle,
            textStyle: commonTextStyle,
            titleTextStyle: commonTextStyle
          },
          height: 800,
          chartArea: {
            width: '80%',
            top: '60',
            height: 500
          },
          tooltip: {
            textStyle: commonTextStyle
          },
          titleTextStyle: {
            fontSize: 16
          },
          annotations: {
            textStyle: commonTextStyle
          },
          legend: {
            textStyle: commonTextStyle
          }
        };
        if (chartType === "ColumnChart") {
          options.vAxis.minValue = 0;
        }
        if (chartType === "ScatterChart") {
          options.legend = {
            position: "none"
          };
          options.chartArea = {
            'width': '80%',
            'height': '80%'
          };
        } else if (dataArray[0].length === 2 && dataArray[0][1] === "") {
          options.legend = {
            position: "none"
          };
        }
        $.extend(options, opts.gchart, extraOptions);
        if (chartType !== "ScatterChart") {
          options.chartArea.width = colKeys.length * 40;
          if (options.chartArea.width < 500) {
            options.chartArea.width = 500;
          }
          options.width = options.chartArea.width + 200;
          if (maxCharsInLegend > 4) {
            options.width += maxCharsInLegend * 6;
            options.chartArea.left = 100;
          }
          if (rowKeys.length > 22) {
            dh = (rowKeys.length - 22) * 6;
            options.height += dh;
            options.chartArea.height += dh;
          }
        }
        result = $("<div>").css({
          width: "100%",
          height: "100%",
          position: 'relative'
        });
        chartHolder = $("<div></div>").css({
          width: "100%",
          height: "800px"
        });
        imageLink = $("<div><a class=\"btn btn-sm btn-default\"><i class=\"far fa-image fa-fw\"></i> " + opts.localeStrings.openAsImage + "</a></div>").css({
          position: 'absolute',
          top: '10px',
          right: '10px'
        });
        $(result[0]).append(chartHolder, imageLink);
        wrapper = new google.visualization.ChartWrapper({
          dataTable: dataTable,
          chartType: chartType,
          options: options
        });
        wrapper.draw(chartHolder[0]);
        imageLink.bind("click", function() {
          return openImageUrl(wrapper.getChart().getImageURI());
        });
        chartHolder.bind("dblclick", function() {
          var editor;
          if (google.visualization.hasOwnProperty('ChartEditor') && google.visualization.ChartEditor === 'function') {
            editor = new google.visualization.ChartEditor();
            google.visualization.events.addListener(editor, 'ok', function() {
              return editor.getChartWrapper().draw(chartHolder[0]);
            });
            return editor.openDialog(wrapper);
          } else {
            return console.log('ChartEditor not loaded');
          }
        });
        return result;
      };
    };
    $.pivotUtilities.gchart_renderers = {
      "Line Chart": makeGoogleChart("LineChart"),
      "Bar Chart": makeGoogleChart("ColumnChart"),
      "Stacked Bar Chart": makeGoogleChart("ColumnChart", {
        isStacked: true
      }),
      "Area Chart": makeGoogleChart("AreaChart", {
        isStacked: true
      }),
      "Scatter Chart": makeGoogleChart("ScatterChart")
    };
    rendererTrans = {
      "Line Chart": "Line Chart",
      "Bar Chart": "Bar Chart",
      "Stacked Bar Chart": "Stacked Bar Chart",
      "Area Chart": "Area Chart",
      "Scatter Chart": "Scatter Chart"
    };
    $.pivotUtilities.locales.en.rendererTrans = $.extend($.pivotUtilities.locales.en.rendererTrans, rendererTrans);
    rendererTrans = {
      "Line Chart": "Линейчатый график",
      "Bar Chart": "Гистограмма",
      "Stacked Bar Chart": "Гистограмма с накоплением",
      "Area Chart": "Диаграммма с областями",
      "Scatter Chart": "Точечная диаграмма"
    };
    return $.pivotUtilities.locales.ru.rendererTrans = $.extend($.pivotUtilities.locales.ru.rendererTrans, rendererTrans);
  });

}).call(this);

//# sourceMappingURL=gchart_renderers.js.map
