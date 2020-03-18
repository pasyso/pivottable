callWithJQuery = (pivotModule) ->
    if typeof exports is "object" and typeof module is "object" # CommonJS
        pivotModule require("jquery")
    else if typeof define is "function" and define.amd # AMD
        define ["jquery"], pivotModule
    # Plain browser env
    else
        pivotModule jQuery

openImageUrl = (url) ->
    iframe = "<iframe src='" + url + "'  style=\"border:0; top:0; left:0; bottom:0; right:0; width:100%; height:100%;\" allowfullscreen></iframe>"
    x = window.open()
    x.document.open()
    x.document.write(iframe)
    x.document.close()

callWithJQuery ($) ->

    makeGoogleChart = (chartType, extraOptions) -> (pivotData, opts) ->
        defaults =
            localeStrings:
                vs: "vs"
                by: "by"
                and: "and"
                openAsImage: "As image"
            gchart: {}

        opts = $.extend true, defaults, opts
        opts.gchart.width ?= window.innerWidth / 1.4
#        opts.gchart.height ?= window.innerHeight / 1.4

        rowKeys = pivotData.getRowKeys()
        rowKeys.push [] if rowKeys.length == 0
        colKeys = pivotData.getColKeys()
        colKeys.push [] if colKeys.length == 0
        fullAggName = $.pivotUtilities.locales[opts.lang].aggregatorTrans[pivotData.aggregatorName]
        if pivotData.valAttrs.length
            fullAggName += "(#{pivotData.valAttrs.join(", ")})"
        headers = ($.pivotUtilities.getValueTranslation(h, opts.localeStrings).join("-") for h in rowKeys)
        headers.unshift ""

        numCharsInHAxis = 0
        if chartType == "ScatterChart"
            dataArray = []
            for y, tree2 of pivotData.tree
                for x, agg of tree2
                     dataArray.push [
                        parseFloat(x),
                        parseFloat(y),
                        fullAggName+": \n"+agg.format(agg.value())
                        ]
            dataTable = new google.visualization.DataTable()
            hAxisTitle = $.pivotUtilities.getTranslation(pivotData.colAttrs,opts.dataTrans).join("-")
            vAxisTitle = $.pivotUtilities.getTranslation(pivotData.rowAttrs,opts.dataTrans).join("-")
            dataTable.addColumn 'number', hAxisTitle
            dataTable.addColumn 'number', vAxisTitle
            dataTable.addColumn type: "string", role: "tooltip"
            dataTable.addRows dataArray
            title = ""
        else
            dataArray = [headers]
            for colKey in colKeys
                row = [ $.pivotUtilities.getValueTranslation(colKey, opts.localeStrings).join("-")]
                numCharsInHAxis += row[0].length
                for rowKey in rowKeys
                    agg = pivotData.getAggregator(rowKey, colKey)
                    if agg.value()?
                        val = agg.value()
                        if $.isNumeric val
                            if val < 1
                                row.push parseFloat(val.toPrecision(3))
                            else
                                row.push parseFloat(val.toFixed(3))
                        else
                            row.push val
                    else row.push null
                dataArray.push row

            maxCharsInLegend = 0
            for rowKey in rowKeys
                len = rowKey.join("-").length
                maxCharsInLegend = len if maxCharsInLegend < len

            dataTable = google.visualization.arrayToDataTable(dataArray)

            title = vAxisTitle = fullAggName
            hAxisTitle = $.pivotUtilities.getTranslation(pivotData.colAttrs,opts.dataTrans).join("-")
            groupByTitle = $.pivotUtilities.getTranslation(pivotData.rowAttrs,opts.dataTrans).join("-")
            if hAxisTitle != "" || groupByTitle != ""
                title += " #{opts.localeStrings.by}"
                title += " #{hAxisTitle}" if hAxisTitle != ""
                title += " #{opts.localeStrings.and}" if hAxisTitle != "" && groupByTitle != ""
                title += " #{groupByTitle}" if groupByTitle != ""

        commonTextStyle = fontSize : 13
        
        options = 
            title: title
            hAxis: title: hAxisTitle,slantedText: numCharsInHAxis > 50,textStyle: commonTextStyle,titleTextStyle: commonTextStyle
            vAxis: title: vAxisTitle,textStyle: commonTextStyle,titleTextStyle: commonTextStyle
            height: 800
            chartArea: {width: '80%', top: '60', height: 500}
            tooltip: textStyle: commonTextStyle
            titleTextStyle: fontSize: 16
            annotations: textStyle: commonTextStyle
            legend: textStyle: commonTextStyle

        if chartType == "ColumnChart"
            options.vAxis.minValue = 0

        if chartType == "ScatterChart"
            options.legend = position: "none"
            options.chartArea = {'width': '80%', 'height': '80%'}

        else if dataArray[0].length == 2 and dataArray[0][1] ==  ""
            options.legend = position: "none"
        
        $.extend options, opts.gchart, extraOptions

        if chartType != "ScatterChart"
            options.chartArea.width = colKeys.length*40
            options.chartArea.width = 500 if options.chartArea.width < 500
            options.width = (options.chartArea.width+200)
            if maxCharsInLegend>4
                options.width += maxCharsInLegend*6
                options.chartArea.left = 100

            if rowKeys.length > 22
                dh =  (rowKeys.length - 22)*6
                options.height += dh
                options.chartArea.height += dh

#        if options.width < opts.gchart.width
#            options.width = opts.gchart.width
#            options.chartArea = width: '80%', top: '60', height: '500'

        result = $("<div>").css(width: "100%", height: "100%", position: 'relative')
        chartHolder = $("<div></div>").css(width: "100%", height: "800px")
        imageLink = $("<div><a class=\"btn btn-sm btn-default\"><i class=\"far fa-image fa-fw\"></i> #{opts.localeStrings.openAsImage}</a></div>").css(position: 'absolute', top:'10px', right:'10px')
        $(result[0]).append(chartHolder,imageLink)
        wrapper = new google.visualization.ChartWrapper {dataTable, chartType, options}
        wrapper.draw(chartHolder[0])
#        imageUrl = wrapper.getChart().getImageURI()
        imageLink.bind "click", ->
            openImageUrl(wrapper.getChart().getImageURI())

        chartHolder.bind "dblclick", ->
            if google.visualization.hasOwnProperty('ChartEditor') and google.visualization.ChartEditor == 'function'
                editor = new google.visualization.ChartEditor()
                google.visualization.events.addListener editor, 'ok', ->
                    editor.getChartWrapper().draw(chartHolder[0])
                editor.openDialog(wrapper)
            else console.log('ChartEditor not loaded')
        return result

    $.pivotUtilities.gchart_renderers = 
        "Line Chart": makeGoogleChart("LineChart")
        "Bar Chart": makeGoogleChart("ColumnChart")
        "Stacked Bar Chart": makeGoogleChart("ColumnChart", isStacked: true)
        "Area Chart": makeGoogleChart("AreaChart", isStacked: true)
        "Scatter Chart": makeGoogleChart("ScatterChart")

    rendererTrans =
        "Line Chart": "Line Chart"
        "Bar Chart": "Bar Chart"
        "Stacked Bar Chart": "Stacked Bar Chart"
        "Area Chart": "Area Chart"
        "Scatter Chart": "Scatter Chart"
    $.pivotUtilities.locales.en.rendererTrans = $.extend($.pivotUtilities.locales.en.rendererTrans,rendererTrans);
    
    rendererTrans =
        "Line Chart": "Линейчатый график"
        "Bar Chart": "Гистограмма"
        "Stacked Bar Chart": "Гистограмма с накоплением"
        "Area Chart": "Диаграммма с областями"
        "Scatter Chart": "Точечная диаграмма"    
    $.pivotUtilities.locales.ru.rendererTrans = $.extend($.pivotUtilities.locales.ru.rendererTrans,rendererTrans);