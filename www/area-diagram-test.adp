<master>
<link rel='stylesheet' href='/sencha-extjs-v421/resources/css/ext-all.css'  type='text/css' media='screen'>
<script type='text/javascript' src='/sencha-extjs-v421-dev/ext-all-debug-w-comments.js'></script>
<div id=diagram_12345></div>
<script type='text/javascript'>

Ext.require(['Ext.chart.*', 'Ext.Window', 'Ext.fx.target.Sprite', 'Ext.layout.container.Fit']);
Ext.onReady(function () {
    
	projectEvaStore = Ext.create('Ext.data.Store', {
		fields: ['date', 'planned_value', 'invoices', 'cost_type_3702', 'cost_type_3703', 'cost_type_3718'],
		data: [
	{'date': '2014-06-16 09:00:00', 'planned_value': 0.0, 'invoices': 0.0, 'cost_type_3702': 0.0, 'cost_type_3703': 0.0, 'cost_type_3718': 0.0},
	{'date': '2014-06-18 09:00:00', 'planned_value': 0.0, 'invoices': 10000.0, 'cost_type_3702': 1000.0, 'cost_type_3703': 0.0, 'cost_type_3718': 510.0},
	{'date': '2014-06-19 19:00:00', 'planned_value': 16000.0, 'invoices': 15000.0, 'cost_type_3702': 5000.0, 'cost_type_3703': 0.0, 'cost_type_3718': 270.0},
	{'date': '2014-06-23 09:00:00', 'planned_value': 16000.0, 'invoices': 25000.0, 'cost_type_3702': 1000.0, 'cost_type_3703': 0.0, 'cost_type_3718': 0.0}
		       ]
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
				 'planned_value', 
				 'invoices'
				 ]
		    }, {
			type: 'Time',
			position: 'bottom',
			fields: 'date',
			dateFormat: 'M d'
		    }],
		series: [{
			type: 'area',
			axis: 'left',
			xField: 'date',
			yField: ['planned_value', 'invoices', 'cost_type_3702', 'cost_type_3703', 'cost_type_3718'],
			highlight: true
		    }]
	    });


	var projectEvaPanel = Ext.create('widget.panel', {
		width: 1000,
		height: 500,
		title: 'Test',
		renderTo: 'diagram_12345',
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
