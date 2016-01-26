<div id=@diagram_id@></div>
<script type='text/javascript'>

Ext.require(['Ext.chart.*', 'Ext.Window', 'Ext.fx.target.Sprite', 'Ext.layout.container.Fit']);
Ext.onReady(function () {
    
    histogramStore = Ext.create('Ext.data.Store', {
	fields: ['category', 'value'],
	data : [
	    @store_json;noquote@
	]
    });
    
    histogramChart = new Ext.chart.Chart({
	title: '@diagram_title@',
	renderTo: '@diagram_id@',
	width: @diagram_width@,
	height: @diagram_height@,
	animate: false,
	store: histogramStore,
	legend: false,
	insetPadding: 20,
	theme: 'Base:gradients',
	axes: [{
	    type: 'category',
	    position: 'left',
	    fields: ['category']
	}, {
	    type: 'numeric',
	    position: 'bottom',
	    fields: 'value'
	}],
	series: [{
	    type: 'line',
	    title: '@diagram_title@',
	    axis: 'bottom',
	    xField: 'value',
	    yField: 'category'
	}]
    });
});
</script>
