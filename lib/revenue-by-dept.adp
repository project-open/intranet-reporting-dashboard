<div id="@diagram_id@" style="height: @diagram_height@px; width: @diagram_width@px"></div>
<script type='text/javascript'>
Ext.require(['Ext.chart.*', 'Ext.Window', 'Ext.fx.target.Sprite', 'Ext.layout.container.Fit']);
Ext.onReady(function () {

    revenueByDeptsStore = Ext.create('Ext.data.Store', {
        fields: @header_json;noquote@,
	autoLoad: true,
	proxy: {
            type: 'rest',
            url: '/intranet-reporting-dashboard/revenue-by-dept.json',
            extraParams: {					// Parameters to the data-source
		diagram_interval: '@diagram_default_interval@',	// 
		diagram_fact: '@diagram_default_fact@',		// 
		diagram_dept_sql: "@diagram_dept_sql;noquote@"	// 
            },
            reader: { type: 'json', root: 'data' }
	}
    });

    var revenueByDeptsIntervalStore = Ext.create('Ext.data.Store', {
        fields: ['display', 'value'],
        data: [
            {"display":"<%=[lang::message::lookup "" intranet-reporting-dashboard.All_Time "All Time"]%>", "value":"all_time"},
            {"display":"<%=[lang::message::lookup "" intranet-reporting-dashboard.Last_Two_Years "Last Two Year"]%>", "value":"last_two_years"},
            {"display":"<%=[lang::message::lookup "" intranet-reporting-dashboard.Last_Year "Last Year"]%>", "value":"last_year"},
            {"display":"<%=[lang::message::lookup "" intranet-reporting-dashboard.Last_Quarter "Last Quarter"]%>", "value":"last_quarter"}
        ]
    });

    var revenueByDeptsFactStore = Ext.create('Ext.data.Store', {
        fields: ['display', 'value'],
        data: [
            {"display":"<%=[lang::message::lookup "" intranet-reporting-dashboard.Revenue "Revenue"]%>", "value":"revenue"},
            {"display":"<%=[lang::message::lookup "" intranet-reporting-dashboard.Profit "Profit"]%>", "value":"profit"},
            {"display":"<%=[lang::message::lookup "" intranet-reporting-dashboard.Internal_Cost "Internal Cost"]%>", "value":"internal_cost"},
            {"display":"<%=[lang::message::lookup "" intranet-reporting-dashboard.External_Cost "External Cost"]%>", "value":"external_cost"}
        ]
    });

    revenueByDeptsChart = new Ext.chart.Chart({
        xtype: 'chart',
        animate: false,
        store: revenueByDeptsStore,
        legend: { position: 'right' },
        insetPadding: 20,
        theme: 'Base:gradients',
        axes: [{
            type: 'Numeric',
            position: 'left',
            fields: @dept_list_json;noquote@,
            title: 'Revenue (x 1000 @default_currency@)'
        }, {
            type: 'Time',
            position: 'bottom',
            fields: ['Date'],
            dateFormat: 'j M y',
            constraint: false,
            step: [Ext.Date.MONTH, 1],
            // fromDate: new Date('2019-01-01'),
            toDate: new Date('@axis_to_date@'),
            label: {rotate: {degrees: 315}}
        }],
        series: @series_list_json;noquote@
    });

    var revenueByDeptsPanel = Ext.create('widget.panel', {
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
                store: revenueByDeptsIntervalStore,
                mode: 'local',
                displayField: 'display',
                valueField: 'value',
                triggerAction: 'all',
                width: 250,
                forceSelection: true,
                value: '@diagram_default_interval@',
                listeners:{select:{fn:function(combo, comboValues) {
                    var value = comboValues[0].data.value;
                    var extraParams = revenueByDeptsStore.getProxy().extraParams;
                    extraParams.diagram_interval = value;
                    revenueByDeptsStore.load();
                }}}
            }, '->', 
            {
                xtype: 'combo',
                editable: false,
                fieldLabel: '<%=[lang::message::lookup "" intranet-reporting-dashboard.Fact_Dimension "Fact Dimension"]%>',
                store: revenueByDeptsFactStore,
                mode: 'local',
                displayField: 'display',
                valueField: 'value',
                triggerAction: 'all',
                width: 250,
                forceSelection: true,
                value: '@diagram_default_fact@',
                listeners:{select:{fn:function(combo, comboValues) {
                    var value = comboValues[0].data.value;
                    var extraParams = revenueByDeptsStore.getProxy().extraParams;
                    extraParams.diagram_fact = value;
                    revenueByDeptsStore.load();
                }}}
            }


        ],
        items: revenueByDeptsChart
    });
});
</script>

