<div id=@diagram_id@></div>
<script type='text/javascript'>

Ext.require([
	'Ext.chart.*', 
	'Ext.Window', 
	'Ext.fx.target.Sprite', 
	'Ext.layout.container.Fit'
]);

Ext.onReady(function () {
    
    histogramStore@diagram_rand@ = Ext.create('Ext.data.Store', {
	fields: [@fields;noquote@],
	data : @store_json;noquote@
    });


<if @chart_type@ eq "default">

    var histogramChart = new Ext.chart.Chart({
            animate: true,
            shadow: true,
	    renderTo: '@diagram_id@',
            store: histogramStore@diagram_rand@,
	    width: '@diagram_width@',
	    height: '@diagram_height@',
//	    width: 'auto',
//	    height: 'auto',
            axes: [{
                type: 'Numeric',
                position: 'bottom',
                fields: ['@axes_bottom_value;noquote@'],
                label: {
                    renderer: Ext.util.Format.numberRenderer('0,0')
                },
                /* title: 'Horizontal Title', */
                grid: true,
                minimum: 0
            }, {
                type: 'Category',
                position: 'left',
                fields: ['@axes_left_value;noquote@'],
                /* title: 'Vertical Title' */   
            }],
	    /* 
            background: {
              gradient: {
                id: 'backgroundGradient',
                angle: 45,
                stops: {
                  0: {
                    color: '#ffffff'
                  },
                  100: {
                    color: '#eaf1f8'
                  }
                }
              }
            },
	    */ 
            series: [{
                type: 'bar',
                axis: 'bottom',
                highlight: true,
                renderer: function(sprite, record, attr, index, store) {
                    return Ext.apply(attr, { fill: '<%=[im_color_code blue_dark ""]%>'});
                },
		/* Tips appearing on "Mouse over" */ 
                tips: {
                  trackMouse: true,
                  width: 140,
                  height: 28,
                  renderer: function(storeItem, item) {
                    this.setTitle(storeItem.get('@axes_left_value;noquote@') + ': ' + storeItem.get('@axes_bottom_value;noquote@'));
                  }
                },
		/* "Labels" show up on top of the bar*/ 
                /* label: {
                  display: 'insideEnd',
                    field: '@axes_bottom_value;noquote@',
                    renderer: Ext.util.Format.numberRenderer('0'), 
                    orientation: 'horizontal',
                    color: '#000',
                    'text-anchor': 'middle'
                }, */
                xField: '@axes_left_value;noquote@',
                yField: ['@axes_bottom_value;noquote@']
            }]
    });

</if>

});
</script>
