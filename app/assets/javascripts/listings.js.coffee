# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#= require jquery-ui/autocomplete
#= require cloudinary

$(document).ready ->
	$('[data-toggle="offcanvas"]').click ->
		$('.row-offcanvas').toggleClass('active') 

split = (val) ->
  val.split( /,\s*/ )
extractLast = (term) ->
  split(term).pop()

$(document).ready ->
  $("#neighborhood_ids").tokenInput "/neighborhoods/index.json",
    crossDomain: false
    queryParam: "term"
    prePopulate: $("#neighborhood_ids").data('pre')
    theme: "facebook"
#    allowFreeTagging: true
#    tokenValue: "name"

$(document).ready ->
  $('#city_name').autocomplete
    source: '/cities/index.json',
    minLength: 2,
    select: ( event, ui ) ->
      if ui.item
        $('#listing_city_id').val(ui.item.id);

map = null
geocoder = null

$(document).ready ->
  if $('#map-canvas').length
    mapCanvas = $('#map-canvas');
    mapOptions =
      center: new google.maps.LatLng 44.5403, -78.5463
      zoom: 16,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    map = new google.maps.Map $('#map-canvas')[0], mapOptions
    geocoder = new google.maps.Geocoder
    codeAddress()
    return

codeAddress = ->
  address = $('#address').data("value")
  geocoder.geocode 'address': address, (results, status) ->
    if status is google.maps.GeocoderStatus.OK
      map.setCenter results[0].geometry.location
      marker = new google.maps.Marker
        map: map,
        position: results[0].geometry.location
    else
      alert('Geocode was not successful for the following reason: ' + status)
    return
  return

$(document).ready -> 
	$(".cloudinary-fileupload").fileupload          
		dropZone: "#direct_upload",		
		start: (e) ->			
			#percents = 0			
			#$('.progress-bar').css('width', percents+'%').attr('aria-valuenow', percents);  
			#$('.sr-only').text(percents+'% Complete')
			return
		progress: (e, data) ->
			#percents = Math.round((data.loaded * 100.0) / data.total)			
			#$('.progress-bar').css('width', percents+'%').attr('aria-valuenow', percents);  
			#$('.sr-only').text(percents+'% Complete')
			return
		fail: (e, data) ->
			$(".status").text("Upload failed")

$(document).ready ->
	$(".cloudinary-fileupload").off("cloudinarydone").on("cloudinarydone", (e, data) ->
		row = $('#photos')
		fields = $('.add_fields').data('fields')		
		time = new Date().getTime()
		regexp = new RegExp($('.add_fields').data('id'), 'g')

		row.append(fields.replace(regexp, time))
		

		$.cloudinary.image(data.result.public_id, options).prependTo(row.find(".thumbnail:last"))
		preview = $(".preview").html('');
		options = 
			format: data.result.format 
			width: 940 
			height: 626 
			crop: "fit"
		$.cloudinary.image(data.result.public_id, options).appendTo(preview)
		upload_info = [data.result.resource_type, data.result.type, data.result.path].join("/") + "#" + data.result.signature;
		$('<input/>').attr({type: "hidden", name: 'listing[property_photos_attributes]['+time+'][photo_url]'}).val(upload_info).appendTo(data.form)
		#view_upload_details(data.result)
		return)
	return

view_upload_details = (upload) ->	
	rows = [];
	$.each(upload, (k,v) ->
		rows.push($("<tr>").append($("<td>").text(k)).append($("<td>").text(JSON.stringify(v))))
		return)

	$("#info").html($("<div class=\"upload_details\">").append("<h2>Upload metadata:</h2>").append($("<table>").append(rows)))
	return

jQuery ->
	$('form').on 'click', '.remove_fields', (event) ->
		$(this).prev('input[type=hidden]').val('1')
		$(this).closest('fieldset').hide()
		event.preventDefault()

#carousel
jQuery ->
  # This is the connector function.
  # It connects one item from the navigation carousel to one item from the
  # stage carousel.
  # The default behaviour is, to connect items with the same index from both
  # carousels. This might _not_ work with circular carousels!
  connector = (itemNavigation, carouselStage) ->
    return carouselStage.jcarousel('items').eq(itemNavigation.index());

  $ ->
    # Setup the carousels. Adjust the options for both carousels here.
    carouselStage      = $('.carousel-stage').jcarousel()
    carouselNavigation = $('.carousel-navigation').jcarousel()

    # We loop through the items of the navigation carousel and set it up
    # as a control for an item from the stage carousel.
    carouselNavigation.jcarousel('items').each( ->
      item = $(this)

      # This is where we actually connect to items.
      target = connector(item, carouselStage);

      item
        .on 'jcarouselcontrol:active', ->
          carouselNavigation.jcarousel('scrollIntoView', this)
          item.addClass('active')
          return
        .on 'jcarouselcontrol:inactive', ->
          item.removeClass('active')
          return
        .jcarouselControl
          target: target,
          carousel: carouselStage
      return
    )
    # Setup controls for the stage carousel
    $('.prev-stage')
      .on 'jcarouselcontrol:inactive', ->
        $(this).addClass('inactive')
        return

      .on 'jcarouselcontrol:active', ->
        $(this).removeClass('inactive')
        return

      .jcarouselControl
        target: '-=1'


    $('.next-stage')
      .on 'jcarouselcontrol:inactive', ->
        $(this).addClass('inactive')
        return

      .on 'jcarouselcontrol:active', ->
        $(this).removeClass('inactive')
        return

      .jcarouselControl
        target: '+=1'


    # Setup controls for the navigation carousel
    $('.prev-navigation')
      .on 'jcarouselcontrol:inactive', ->
        $(this).addClass('inactive')
        return

      .on 'jcarouselcontrol:active', ->
        $(this).removeClass('inactive');
        return

      .jcarouselControl
        target: '-=1'


    $('.next-navigation')
      .on 'jcarouselcontrol:inactive', ->
        $(this).addClass('inactive')
        return

      .on 'jcarouselcontrol:active', ->
        $(this).removeClass('inactive')
        return

      .jcarouselControl
        target: '+=1'
    return
  return