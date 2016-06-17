<if @project_count@ ge 2>

<div id=@diagram_id@></div>
<script type='text/javascript'>
Ext.require(['Ext.chart.*', 'Ext.Window', 'Ext.fx.target.Sprite', 'Ext.layout.container.Fit']);

    window.store1 = Ext.create('Ext.data.JsonStore', {
        fields: ['x_axis', 'y_axis', 'color', 'diameter', 'caption', 'url'],
        data: @data_json;noquote@
    });

    function createHandler(fieldName) {
        return function(sprite, record, attr, index, store) {
            return Ext.apply(attr, {
                radius: record.get('diameter'),
                fill: record.get('color')
            });
        };
    }

Ext.onReady(function () {
    
    chart = new Ext.chart.Chart({
        width: @diagram_width@,
        height: @diagram_height@,
        animate: true,
        store: store1,
        renderTo: '@diagram_id@',
	axes: [{
	    @axis_y_title_json;noquote@
	    type: 'Numeric',
	    position: 'left',
	    fields: ['y_axis'],
	    grid: true
	}, {
	    @axis_x_title_json;noquote@
	    type: 'Numeric',
	    position: 'bottom',
	    fields: ['x_axis']
	}],
	series: [{
	    type: 'scatter',
	    axis: 'left',
	    xField: 'x_axis',
	    yField: 'y_axis',
	    highlight: true,
	    markerConfig: { type: 'circle' },
	    renderer: createHandler('xxx'),
	    label: {
                display: 'under',
                field: 'caption',
                'text-anchor': 'left',
		color: '#000'
            },
	    listeners: {
		itemmousedown: function(obj) {
		    var url = obj.storeItem.data['url'];
		    window.open(url, "_blank");
		}
	    },
	    tips: {
	        trackMouse: false,
		anchor: 'right',
  		width: 200,
  		height: 50,
  		renderer: function(storeItem, item) {
		    var xTitle = '';
		    var yTitle = '';
		    if ("" != '@diagram_x_title;noquote@') { xTitle = '@diagram_x_title;noquote@='; }
		    if ("" != '@diagram_y_title;noquote@') { yTitle = '@diagram_y_title;noquote@='; }
  		    this.setTitle(
			"<a href='"+storeItem.get('url')+"' target='_blank'>" + 
			    storeItem.get('caption') + ":<br>\n" +
			    xTitle + storeItem.get('x_axis') + ', ' + 
			    yTitle + storeItem.get('y_axis') +
			    "</a>"
		    );
 	        }
            }
	}]
    }
)});
</script>

</if>

