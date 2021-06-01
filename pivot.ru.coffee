callWithJQuery = (pivotModule) ->
    if typeof exports is "object" and typeof module is "object" # CommonJS
        pivotModule require("jquery")
    else if typeof define is "function" and define.amd # AMD
        define ["jquery"], pivotModule
    # Plain browser env
    else
        pivotModule jQuery
    
callWithJQuery ($) ->
    nf = $.pivotUtilities.numberFormat
    tpl = $.pivotUtilities.aggregatorTemplates

    frFmt =    nf(thousandsSep: " ", decimalSep: ",")
    frFmtInt = nf(digitsAfterDecimal: 0, thousandsSep: " ", decimalSep: ",")
    frFmtPct = nf(digitsAfterDecimal: 1, scaler: 100, suffix: "%", thousandsSep: " ", decimalSep: ",")
#    rendererNames = ["Таблица","График столбцы","Теплова карта","Тепловая карта по строке","Тепловая карта по столбцу"]
    
    $.pivotUtilities.locales.ru = 
        localeStrings:
            renderError: "Ошибка рендеринга страницы."
            computeError: "Ошибка табличных расчетов."
            uiRenderError: "Ошибка во время прорисовки и динамического расчета таблицы."
            selectAll: "Выбрать все"
            selectNone: "Ничего не выбирать"
            tooMany: "(Выбрано слишком много значений)"
            filterResults: "Значение фильтра"
            totals: "Всего"
            vs: "на"
            by: "по"
            and: "и"
            openAsImage: "Открыть как изображение"
            b_true: "ИСТИНА"
            b_false: "ЛОЖЬ"
            no_data: "Нет данных"
            exportXlsx: "Экспортировать как XLSX"
        rendererTrans:
            "Table":          "Таблица"
            "Table Barchart": "График столбцы"
            "Heatmap":        "Теплова карта"
            "Row Heatmap":    "Тепловая карта по строке"
            "Col Heatmap":    "Тепловая карта по столбцу"
        aggregatorTrans:
            "Count":                "Количество"
            "Count Unique Values":  "Количество уникальных"
            "List Unique Values":   "Список уникальных"
            "Sum":                  "Сумма"
            "Integer Sum":          "Сумма целых"
            "Average":              "Среднее"
            "Minimum":              "Минимум"
            "Maximum":              "Максимум"
            "Sum over Sum":         "Сумма в Сумме"
            "80% Upper Bound":      "80% верхней границы"
            "80% Lower Bound":      "80% нижней границы"
            "Sum as Fraction of Total":     "Доля от общей суммы"
            "Sum as Fraction of Rows":      "Доля от суммы по строке"
            "Sum as Fraction of Columns":   "Доля от суммы по столбцу"
            "Count as Fraction of Total":   "Счет по всему"
            "Count as Fraction of Rows":    "Счет по строке"
            "Count as Fraction of Columns": "Счет по столбцу"
