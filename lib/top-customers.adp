<div id="@diagram_id@" style="height: @diagram_height@px; width: @diagram_width@px"></div>
<script type='text/javascript'>
Ext.require(['Ext.chart.*', 'Ext.Window', 'Ext.fx.target.Sprite', 'Ext.layout.container.Fit']);
Ext.onReady(function () {
    
    topCustomersStore = Ext.create('Ext.data.Store', {
        fields: ['name', 'value'],
	autoLoad: true,
	proxy: {
            type: 'rest',
            url: '/intranet-reporting-dashboard/top-customers.json',
            extraParams: {				// Parameters to the data-source
		diagram_interval: 'all_time',		// Number of customers to show
		diagram_max_customers: 8,		// Number of customers to show
		diagram_max_length_customer_name: 15	// Limit the length of the customer name
            },
            reader: { type: 'json', root: 'data' }
	}
    });

    var topCustomersIntervalStore = Ext.create('Ext.data.Store', {
	fields: ['display', 'value'],
	data : [
            {"display":"<%=[lang::message::lookup "" intranet-reporting-dashboard.All_Time "All time"]%>", "value":"all_time"},
            {"display":"<%=[lang::message::lookup "" intranet-reporting-dashboard.Last_Year "Last Year"]%>", "value":"last_year"},
            {"display":"<%=[lang::message::lookup "" intranet-reporting-dashboard.Last_Quarter "Last Quarter"]%>", "value":"last_quarter"}
	]
    });

    topCustomersChart = new Ext.chart.Chart({
	xtype: 'chart',
	animate: true,
	store: topCustomersStore,
	legend: { position: 'right' },
	insetPadding: 20,
	theme: 'Base:gradients',
	series: [{
	    type: 'pie',
	    field: 'value',
	    showInLegend: true,
	    donut: false,
	    label: {
		field: 'name',
		display: 'rotate',
                font: '11px Arial'
	    },
	    tips: {
                width: 140,
                height: 50,
                renderer: function(storeItem, item) {
                    var total = 0;                    //calculate percentage.
                    topCustomersStore.each(function(rec) { total += rec.get('value'); });
                    this.setTitle(storeItem.get('name') + ':<br>' + Math.round(storeItem.get('value') / total * 100) + '%');
                }
	    },
	    highlight: {
		segment: { margin: 20 }
	    }
	}]
    });

    var topCustomersPanel = Ext.create('widget.panel', {
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
		store: topCustomersIntervalStore,
		mode: 'local',
		displayField: 'display',
		valueField: 'value',
		triggerAction: 'all',
		width: 150,
		forceSelection: true,
		value: 'all_time',
		listeners:{select:{fn:function(combo, comboValues) {
		    var value = comboValues[0].data.value;
		    var extraParams = topCustomersStore.getProxy().extraParams;
		    extraParams.diagram_interval = value;
		    topCustomersStore.load();
		}}}
            }
	],
        items: topCustomersChart
    });
});
</script>
