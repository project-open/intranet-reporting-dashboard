<div id="@diagram_id@" style="height: @diagram_height@px; width: @diagram_width@px"></div>
<script type='text/javascript'>
Ext.require(['Ext.chart.*', 'Ext.Window', 'Ext.fx.target.Sprite', 'Ext.layout.container.Fit']);
Ext.onReady(function () {

    // The store with revenue by department data
    var revenueByYearsStore = Ext.create('Ext.data.Store', {
        fields: @header_json;noquote@,
	autoLoad: false,						// load handled manually
	proxy: {
            type: 'rest',
            url: '/intranet-reporting-dashboard/revenue-by-year-monthly.json',	// data-source for this indicator
            extraParams: {							// Parameters to the data-source
		diagram_interval: '@diagram_default_interval@',		// default interval to start with ('all_time')
		diagram_fact: '@diagram_default_fact@'			// Revenue or profit?
            },
            reader: { type: 'json', root: 'data' }
	},
	data: [								// Dummy content for store to avoid slow display since 1970-01-01...
	    {'month': 'month_01', 'invoices_2017': 100}
	]
    });

    // value range for time interval select box
    var revenueByYearsIntervalStore = Ext.create('Ext.data.Store', {
        fields: ['display', 'value'],
        data: [
            {"display":"<%=[lang::message::lookup "" intranet-reporting-dashboard.All_Time "All Time"]%>", "value":"all_time"},
            {"display":"<%=[lang::message::lookup "" intranet-reporting-dashboard.Last_Two_Years "Last Two Years"]%>", "value":"last_two_years"},
            {"display":"<%=[lang::message::lookup "" intranet-reporting-dashboard.Last_Year "Last Year"]%>", "value":"last_year"},
            {"display":"<%=[lang::message::lookup "" intranet-reporting-dashboard.Last_Quarter "Last Quarter"]%>", "value":"last_quarter"}
        ]
    });

    // value range for what to show (revenue vs. profit)
    var revenueByYearsFactStore = Ext.create('Ext.data.Store', {
        fields: ['display', 'value'],
        data: [
            {"display":"<%=[lang::message::lookup "" intranet-reporting-dashboard.Revenue "Revenue"]%>", "value":"revenue"},
            {"display":"<%=[lang::message::lookup "" intranet-reporting-dashboard.Profit "Profit"]%>", "value":"profit"},
            {"display":"<%=[lang::message::lookup "" intranet-reporting-dashboard.Internal_Cost "Internal Cost"]%>", "value":"internal_cost"},
            {"display":"<%=[lang::message::lookup "" intranet-reporting-dashboard.External_Cost "External Cost"]%>", "value":"external_cost"}
        ]
    });

    // simple diagram...
    revenueByYearsChart = new Ext.chart.Chart({
        xtype: 'chart',
        animate: false,
        store: revenueByYearsStore,
        legend: { position: 'right' },
        theme: 'Base:gradients',
        axes: [{
            type: 'Numeric',
            position: 'left',
            fields: @year_list_json;noquote@,
            title: 'Revenue (x 1000 @default_currency@)'
        }, {
            title: false,
            type: 'Category',
            position: 'bottom',
            fields: ['month'],
	    label: {
		rotate: {degrees: 315},
                renderer: function(v) {
		    return Ext.Date.format(v, 'M y'); 
                }
	    }
        }],
        series: @series_list_json;noquote@
    });

    // Window around diagram with drop select boxes that reload data when operated
    var revenueByYearsPanel = Ext.create('widget.panel', {
        width: @diagram_width@,
        height: @diagram_height@,
        title: '@diagram_title@',
        renderTo: '@diagram_id@',
        layout: 'fit',
        header: false,
        tbar: [
            {
                xtype: 'combo',
                editable: false,
                fieldLabel: '<%=[lang::message::lookup "" intranet-reporting-dashboard.Interval Interval]%>',
                store: revenueByYearsIntervalStore,
                mode: 'local',
                displayField: 'display',
                valueField: 'value',
                triggerAction: 'all',
                width: 250,
                forceSelection: true,
                value: '@diagram_default_interval@',
                listeners:{select:{fn:function(combo, comboValues) {
                    var value = comboValues[0].data.value;
                    var extraParams = revenueByYearsStore.getProxy().extraParams;
                    extraParams.diagram_interval = value;
                    revenueByYearsStore.load();
                }}}
            }, '->', 
            {
                xtype: 'combo',
                editable: false,
                fieldLabel: '<%=[lang::message::lookup "" intranet-reporting-dashboard.Fact_Dimension "Fact Dimension"]%>',
                store: revenueByYearsFactStore,
                mode: 'local',
                displayField: 'display',
                valueField: 'value',
                triggerAction: 'all',
                width: 250,
                forceSelection: true,
                value: '@diagram_default_fact@',
                listeners:{select:{fn:function(combo, comboValues) {
                    var value = comboValues[0].data.value;
                    var extraParams = revenueByYearsStore.getProxy().extraParams;
                    extraParams.diagram_fact = value;
                    revenueByYearsStore.load();
                }}}
            }


        ],
        items: revenueByYearsChart
    });

    revenueByYearsStore.load();
});
</script>




<!--



Ext.require(['Ext.chart.*', 'Ext.Window', 'Ext.fx.target.Sprite', 'Ext.layout.container.Fit']);
Ext.onReady(function () {

    // value range for time interval select box
    var revenueByMonthsIntervalStore = Ext.create('Ext.data.Store', {
        fields: ['display', 'value'],
        data: [
            {"display":"All Time", "value":"all_time"},
            {"display":"Last Two Years", "value":"last_two_years"},
            {"display":"Last Year", "value":"last_year"},
            {"display":"Last Quarter", "value":"last_quarter"}
        ]
    });

    // value range for what to show (revenue vs. profit)
    var revenueByMonthsFactStore = Ext.create('Ext.data.Store', {
        fields: ['display', 'value'],
        data: [
            {"display":"Revenue", "value":"revenue"},
            {"display":"Internal Cost", "value":"internal_cost"},
            {"display":"External Cost", "value":"external_cost"}
        ]
    });

    // simple diagram...
    revenueByMonthsChart = new Ext.chart.Chart({
        xtype: 'chart',
        animate: false,
        store: revenueByMonthsStore,
        legend: { position: 'right' },
        theme: 'Base:gradients',
        axes: [{
            type: 'Numeric',
            position: 'left',
            fields: ['2017', '2018', '2019'],
            title: 'x 1000 EUR'
        }, {
            title: false,
            type: 'Category',
            position: 'bottom',
            fields: ['Month'],
	    label: {rotate: {degrees: 315} }
        }],
        series: [
            {
                type: 'line',
                title: '2017', 
                xField: 'Month', yField: '2017', 
                axis: 'left', 
                highlight: {size: 7, radius: 7}
            },
            {
                type: 'line',
                title: '2018', 
                xField: 'Month', yField: '2018', 
                axis: 'left', 
                highlight: {size: 7, radius: 7}
            },
            {
                type: 'line',
                title: '2019', 
                xField: 'Month', yField: '2019', 
                axis: 'left', 
                highlight: {size: 7, radius: 7}
            }
        ]
    });

    // Window around diagram with drop-down boxes that reload data when operated
    var revenueByMonthsPanel = Ext.create('widget.panel', {
        width: 600,
        height: 500,
        title: 'Revenue by Month',
        renderTo: 'revenu_by_year_80939009',
        layout: 'fit',
        header: false,
        tbar: [
            {
                xtype: 'combo',
                editable: false,
                fieldLabel: 'Interval',
                store: revenueByMonthsIntervalStore,
                mode: 'local',
                displayField: 'display',
                valueField: 'value',
                triggerAction: 'all',
                width: 250,
                forceSelection: true,
                value: 'last_year',
                listeners:{select:{fn:function(combo, comboValues) {
                    var value = comboValues[0].data.value;
                    var extraParams = revenueByMonthsStore.getProxy().extraParams;
                    extraParams.diagram_interval = value;
                    revenueByMonthsStore.load();
                }}}
            }, '->', 
            {
                xtype: 'combo',
                editable: false,
                fieldLabel: 'Fact Dimension',
                store: revenueByMonthsFactStore,
                mode: 'local',
                displayField: 'display',
                valueField: 'value',
                triggerAction: 'all',
                width: 250,
                forceSelection: true,
                value: 'revenue',
                listeners:{select:{fn:function(combo, comboValues) {
                    var value = comboValues[0].data.value;
                    var extraParams = revenueByMonthsStore.getProxy().extraParams;
                    extraParams.diagram_fact = value;
                    revenueByMonthsStore.load();
                }}}
            }
        ],
        items: revenueByMonthsChart
    });

    revenueByMonthsStore.load();
});
</script>
</div>


-->
