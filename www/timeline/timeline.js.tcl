ad_page_contract {
    Jason data for Smile Timeline Widget
} {
    { return_url "" }
}

# Default color for project bars
set default_on_track_color "#58A0DC"

# Default Currency
set default_currency [ad_parameter -package_id [im_package_cost_id] "DefaultCurrency" "" "EUR"]

set currency_format [im_l10n_sql_currency_format]

set page_body "
{
    'dateTimeFormat': 'iso8601',
    'events' : \[
"

set main_projects_sql "
	select	p.*,
		im_category_from_id(p.project_status_id) as project_status,
		im_name_from_user_id(p.project_lead_id) as project_lead_name,
		to_char(p.start_date, 'YYYY-MM-DD') as start_date_iso,
		to_char(p.end_date, 'YYYY-MM-DD') as end_date_iso,
		round(10.0 * p.percent_completed) / 10.0 as percent_completed_pretty,
		to_char(p.project_budget, :currency_format) as project_budget_pretty
	from	im_projects p
	where	p.parent_id is null and
		p.project_status_id in ([join [im_sub_categories [im_project_status_open]] ","]) and
		p.project_type_id not in ([im_project_type_task], [im_project_type_ticket])
	order by
		start_date DESC
"
db_foreach main_projects $main_projects_sql {

    set traffic_gif [im_project_on_track_bb $on_track_status_id]

    set on_track_color "green"
    set on_track_name "Green"
    switch $on_track_status_id {
	66 { 
		set on_track_color "green"
		set on_track_name "Green"
	   }
	67 { 
		set on_track_color "orange" 
		set on_track_name "Orange"
	   }
	68 { 
		set on_track_color "red" 
		set on_track_name "Red"
	   }
    }
    set bar_color $on_track_color
    if {"green" == $bar_color} { set bar_color $default_on_track_color }

    set ss_link [export_vars -base "/intranet-simple-survey/reporting/project-reports" {project_id}]
    set pm_link "<a href=/intranet/users/view?user_id=$project_lead_id>$project_lead_name</a>"
    set icon "bb_${on_track_color}.gif"
    set budget_text ""
    if {"" != $project_budget} { append budget_text "$project_budget_pretty $default_currency" }
    if {"" != $budget_text && "" != $project_budget_hours} { append budget_text ", " }
    append budget_text "$project_budget_hours [lang::message::lookup "" intranet-core.hours "hours"]"

    set description "\
	Status: $traffic_gif <a href=$ss_link>\
		[lang::message::lookup "" intranet-core.see_details_and_history "(see details & history)"]</a><br>\
	Manager: $pm_link<br>\
	Budget: $budget_text<br>\
	Done: $percent_completed_pretty %<br>\
    "

    append page_body "
        {
	'start': '$start_date_iso',
        'end': '$end_date_iso',
        'title': '$project_name',
        'durationEvent' : true,
        'description': '$description',
	'caption': '$project_name',
        'link': '[export_vars -base "/intranet/projects/view" {project_id}]',
	'color' : '$bar_color',
        'textColor' : 'black'
        },
    "
}
append page_body "
    \]
}
"
doc_return 200 "text/jason" $page_body

set ttt {
        'link': 'http://www.allposters.com/-sp/Landschaft-bei-Montreuil-Posters_i339007_.htm',
        'isDuration' : false,
        'icon' : "dark-red-circle.png",        
        'color' : 'red',
        'textColor' : 'green'},

        {'start': '1885',
        'end': '1925',
        'title': 'Test 4',
        'description': 'Test 4: tapeImage, caption, classname attributes',
        'image': 'http://images.allposters.com/images/CORPOD/IX001463_b.jpg',
        'link': 'http://www.allposters.com/-sp/Castor-Et-Pollux-Posters_i831718_.htm',
        'tapeImage': 'blue_stripes.png',
        'tapeRepeat': 'repeat-x',
        'caption': "This is the event's caption attribute.",
        'classname': 'hot_event' 
        },

        {'start': '1920',
        'title': 'Femme au Miroir',
        'description': 'by Fernand Leger, French Painter, 1881-1955',
        'image': 'http://images.allposters.com/images/AWI/GMR117_b.jpg',
        'link': 'http://www.allposters.com/-sp/Femme-au-Miroir-1920-Posters_i141266_.htm'
        },


        {'start': '1903',
        'title': 'The Old Guitarist',
        'description': 'by Pablo Picasso, Spanish Painter/Sculptor, 1881-1973',
        'image': 'http://images.allposters.com/images/ESC/AP599_b.jpg',
        'link': 'http://www.allposters.com/-sp/The-Old-Guitarist-c-1903-Posters_i328746_.htm'
        },


        {'start': '1882',
        'end': '1964',
        'title': 'Jour',
        'description': 'by Georges Braque, French Painter, 1882-1963',
        'image': 'http://images.allposters.com/images/SHD/S1041_b.jpg',
        'link': 'http://www.allposters.com/-sp/Jour-Posters_i126663_.htm',
        'color': 'green'
        },


        {'start': '1916',
        'title': 'Still Life with a White Dish',
        'description': 'by Gino Severini, Italian Painter, 1883-1966',
        'image': 'http://images.allposters.com/images/MCG/FS1254_b.jpg',
        'link': 'http://www.allposters.com/-sp/Still-Life-with-a-White-Dish-1916-Posters_i366823_.htm'
        },


        {'start': '1885',
        'end': '1941',
        'title': 'Rhythm, Joie de Vivre',
        'description': 'by Robert Delaunay, French Painter, 1885-1941',
        'image': 'http://imagecache2.allposters.com/images/pic/adc/10053983a_b~Rhythm-Joie-de-Vivre-Posters.jpg',
        'link': 'http://www.allposters.com/-sp/Rhythm-Joie-de-Vivre-Posters_i1250641_.htm'
        },


        {'start': '1912',
        'title': 'Portrait of Pablo Picasso',
        'description': 'by Juan Gris, Spanish Painter/Sculptor, 1887-1927',
        'image': 'http://images.allposters.com/images/BRGPOD/156514_b.jpg',
        'link': 'http://www.allposters.com/-sp/Portrait-of-Pablo-Picasso-1881-1973-1912-Posters_i1344154_.htm'
        },


        {'start': '1891',
        'end': '1915',
        'title': 'Portrait of Horace Brodsky',
        'description': 'by Henri Gaudier-Brzeska, French Sculptor, 1891-1915',
        'image': 'http://imagecache2.allposters.com/images/BRGPOD/102770_b.jpg',
        'link': 'http://www.allposters.com/-sp/Portrait-of-Horace-Brodsky-Posters_i1584413_.htm'
        }
    }