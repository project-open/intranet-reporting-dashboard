<div id=@diagram_id@></div>
<script type='text/javascript'>

Ext.require(['Ext.chart.*', 'Ext.Window', 'Ext.fx.target.Sprite', 'Ext.layout.container.Fit']);
Ext.onReady(function () {
    
	projectEvaStore = Ext.create('Ext.data.Store', {
		fields: ['date', 'planned_ts_value', 'total_planned_ts_value', 'timesheet', 'invoice', 'quote', 'po'],
		autoLoad: true,
		proxy: {
		    type: 'rest',
		    url: '/intranet-reporting-dashboard/project-eva.json',
		    extraParams: {						// Parameters to the data-source
			diagram_project_id: @diagram_project_id@		// Number of customers to show
		    },
		    reader: { type: 'json', root: 'data' }
		}
	    });

	projectEvaChart = new Ext.chart.Chart({
		animate: false,
		store: projectEvaStore,
		legend: { position: 'right' },
		insetPadding: 20,
		theme: 'Base:gradients',
		axes: [{
			type: 'Numeric',
			minimum: 0,
			position: 'left',
			fields: [
				 'planned_ts_value', 
				 'invoice', 
				 'quote', 
				 'po', 
				 'timesheet'
				 ]
		    }, {
			type: 'Time',
			position: 'bottom',
			fields: 'date',
			dateFormat: 'M d'
		    }],
		series: [{
			// Planned value composed of planned timesheet plus POs (purchase orders - external costs)
			type: 'area',
			axis: 'left',
			xField: 'date',
			yField: ['planned_ts_value', 'po'],
			highlight: true
		    }, {
			// Horizontal line for total planned value
			type: 'line',
			title: '@axis_title_total_planned_ts_value_l10n@',
			axis: 'left',
			xField: 'date',
			yField: 'total_planned_ts_value',
			showMarkers: false,
			style: { fill: '#FF0000', stroke: '#FF0000', 'stroke-width': 1 }
		    }, {
			// Invoices
			type: 'line',
			title: '@axis_title_invoices_l10n@',
			axis: 'left',
			xField: 'date',
			yField: 'invoice',
			showMarkers: false,
			style: { stroke: '#@invoice_color@', 'stroke-width': 1 }
		    }, {
			// Quotes
			type: 'line',
			title: '@axis_title_quotes_l10n@',
			axis: 'left',
			xField: 'date',
			yField: 'quote',
			showMarkers: false,
			style: { stroke: '#@quote_color@', 'stroke-width': 1 }
		    }, {
			// Actual costs area chart
			type: 'area',
			axis: 'left',
			xField: 'date',
			yField: ['timesheet', 'bills', 'expbundle'],
			showMarkers: false,
			tips: {
			    trackMouse: false,
			    renderer: function(storeItem, item) {
				this.setTitle(storeItem.get('date'));
				this.update(storeItem.get('total_planned_ts_value'));
			    }
			},
			style: {
			    fill: '#FF0000',
			    stroke: '#FF0000',
			    'stroke-width': 1
			}
		    }]
	    });


	var projectEvaPanel = Ext.create('widget.panel', {
		width: @diagram_width@,
		height: @diagram_height@,
		title: '@diagram_title@',
		renderTo: '@diagram_id@',
		layout: 'fit',
		header: false,
		tbar: [{
			xtype: 'combo',
			editable: false,
			store: false,
			mode: 'local',
			displayField: 'display',
			valueField: 'value',
			triggerAction: 'all',
			width: 150,
			forceSelection: true,
			value: 'all_time',
			listeners:{select:{fn:function(combo, comboValues) {
				    var value = comboValues[0].data.value;
				    var extraParams = projectEvaStore.getProxy().extraParams;
				    extraParams.diagram_interval = value;
				    projectEvaStore.load();
				}
			    }
			}
		    }],
		items: projectEvaChart
	    });
    });
</script>
