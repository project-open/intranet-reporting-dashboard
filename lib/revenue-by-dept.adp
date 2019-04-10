<div id="@diagram_id@" style="height: @diagram_height@px; width: @diagram_width@px"></div>
<script type='text/javascript'>
Ext.require(['Ext.chart.*', 'Ext.Window', 'Ext.fx.target.Sprite', 'Ext.layout.container.Fit']);
Ext.onReady(function () {
    
    revenueByDeptsStore = Ext.create('Ext.data.Store', {
        fields: @header_json;noquote@,
        data: [
@data;noquote@
        ]
    });

    var revenueByDeptsIntervalStore = Ext.create('Ext.data.Store', {
        fields: ['display', 'value'],
        data: [
            {"display":"<%=[lang::message::lookup "" intranet-reporting-dashboard.All_Time "All time"]%>", "value":"all_time"},
            {"display":"<%=[lang::message::lookup "" intranet-reporting-dashboard.Last_Year "Last Year"]%>", "value":"last_year"},
            {"display":"<%=[lang::message::lookup "" intranet-reporting-dashboard.Last_Quarter "Last Quarter"]%>", "value":"last_quarter"}
        ]
    });

    revenueByDeptsChart = new Ext.chart.Chart({
        xtype: 'chart',
        animate: true,
        store: revenueByDeptsStore,
        legend: { position: 'right' },
        insetPadding: 20,
        theme: 'Base:gradients',

        axes: [{
            type: 'Numeric',
            position: 'left',
            fields: @dept_list_json;noquote@,
            title: 'Revenue (in 1000 USD)'
        }, {
            type: 'Time',
            position: 'bottom',
            fields: ['Date'],
            dateFormat: 'j M y',
            constraint: false,
            step: [Ext.Date.MONTH, 1],
            // fromDate: new Date('2019-01-01'),
            // toDate: new Date('2019-06-01'),
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
                // fieldLabel: '<%=[lang::message::lookup "" intranet-reporting-dashboard.Interval Interval]%>',
                store: revenueByDeptsIntervalStore,
                mode: 'local',
                displayField: 'display',
                valueField: 'value',
                triggerAction: 'all',
                width: 150,
                forceSelection: true,
                value: 'all_time',
                listeners:{select:{fn:function(combo, comboValues) {
                    var value = comboValues[0].data.value;
                    var extraParams = revenueByDeptsStore.getProxy().extraParams;
                    extraParams.diagram_interval = value;
                    revenueByDeptsStore.load();
                }}}
            }
        ],
        items: revenueByDeptsChart
    });
});
</script>

