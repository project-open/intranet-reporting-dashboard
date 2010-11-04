<html> 
  <head> 
    <title>SIMILE Widgets | Timeline | Examples | Test Example</title> 
    <script src="http://api.simile-widgets.org/timeline/2.3.1/timeline-api.js?bundle=true" type="text/javascript"></script> 
    <link rel='stylesheet' href='timeline-styles.css' type='text/css' />
    <script> 
        var tl;
        function onLoad() {
            var eventSource = new Timeline.DefaultEventSource(0);          
            var theme = Timeline.ClassicTheme.create();
            theme.event.bubble.width = 350;
            theme.event.bubble.height = 300;
            
            var d = Timeline.DateTime.parseGregorianDateTime("@start_date@")
            var bandInfos = [
                Timeline.createBandInfo({
                    width:          "80%", 
                    intervalUnit:   Timeline.DateTime.MONTH, 
                    intervalPixels: 200,
                    eventSource:    eventSource,
                    date:           d,
                    theme:          theme,
                    layout:         'original'  // original, overview, detailed
                }),
                Timeline.createBandInfo({
                    width:          "20%", 
                    intervalUnit:   Timeline.DateTime.YEAR, 
                    intervalPixels: 200,
                    eventSource:    eventSource,
                    date:           d,
                    theme:          theme,
                    layout:         'overview'  // original, overview, detailed
                })
            ];
            bandInfos[1].syncWith = 0;
            bandInfos[1].highlight = true;
                        
            tl = Timeline.create(document.getElementById("tl"), bandInfos, Timeline.HORIZONTAL);
            // Adding the date to the url stops browser caching of data during testing or if
            // the data source is a dynamic query...
            tl.loadJSON("timeline.js?"+ (new Date().getTime()), function(json, url) {
                eventSource.loadJSON(json, url);
            });
        }
        var resizeTimerID = null;
        function onResize() {
            if (resizeTimerID == null) {
                resizeTimerID = window.setTimeout(function() {
                    resizeTimerID = null;
                    tl.layout();
                }, 500);
            }
        }
    </script> 
 
    <style type="text/css"> 
      /* These css rules are used to modify the display of events with classname attribute */
      /* In a production system, the rules should be in an external css file to enable     */
      /* shared use and caching                                                            */
      .special_event {font-variant: small-caps; font-weight: bold;}
    </style> 
  </head> 
  <body onload="onLoad();" onresize="onResize();"> 
    <ul id="path"> 
      <li><a href="/" title="Home">SIMILE Widgets</a></li> 
      <li><a href="../../" title="Timeline">Timeline</a></li> 
      <li><a href="../" title="Examples">Examples</a></li> 
      <li><span>Event Attribute Tests</span></li> 
    </ul> 
  
    <div id="header"> 
      <h1>Event Attribute Tests</h1> 
    </div> 
  
    <div id="content"> 
      <p>This test uses <a href="test.js">JSON data</a>.</p> 
      <p>It demonstrates use of various event attributes <i>color</i>, <i>textColor</i>, <i>tapeImage</i>, and <i>tapeRepeat</i>. <a href='http://code.google.com/p/simile-widgets/wiki/Timeline_EventSources'>Details</a></p> 
      <p>Test numbers:
        <ol> 
            <li>Only start date</li> 
            <li>Start and end dates. Combinations of isDuration</li> 
            <li>Red tapes. Events without titles. Start and end dates. Combinations of isDuration</li> 
            <li>Caption and tapeImage attributes. The striped tape. Hover over the label or tape to view the caption.</li> 
            <li>Really long labels. They should not wrap</li> 
            <li>Permutations of bad dates. Test that error messages are shown in all browsers including IE</li> 
            <li>Event has classname attribute. CSS is used to modify the event's display. For event with classname of special_event, use css selectors:
            <ul><li>.tape-special_event for the tape in a main band</li> 
                <li>.label-special_event for the label</li> 
                <li>.icon-special_event for the icon</li> 
                <li>.highlight-special_event for the highlight div</li> 
                <li>In addition to the above, the elements also have a class of just special_event. So the selector .special_event can be used generically for all of the above elements, depending on your goals.</li> 
                <li>The events in the overview band will have class .small-special_event for the tape or tick.</li> 
            </ul> 
        </ol> 
          
        Additional features demonstrated:
        <ul> 
          <li>Default Timeline <i>Theme</i> is modified (see html file source).</li> 
          <li>Modified theme: thicker event tapes and increased track size appropriately to match.</li> 
          <li>Modified theme: Popup bubble dimensions set explicitly.</li> 
        </ul> 
      </p> 
      
      <p>Timeline version <span id='tl_ver'></span>.</p> 
      <script>Timeline.writeVersion('tl_ver')</script> 
      
      <p>Stripe courtesy of <a href='http://www.stripegenerator.com/'>Stripe Generator</a>.
        
      <div id="tl" class="timeline-default" style="height: 400px;"></div> 
    </div> 
    
    <div id="footer"> 
      Copyright &copy; <a href="http://web.mit.edu/">Massachusetts Institute of Technology</a> and Contributors 2006-2009 ~ Some rights reserved
    </div> 
  </body> 
</html> 

