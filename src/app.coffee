class Webdlmon
  constructor: ->
    new Webdlmon.Routers.Dataloggers
    Backbone.history.start()

class Webdlmon.Models
class Webdlmon.Collections
class Webdlmon.Views
class Webdlmon.Routers

class Webdlmon.Models.Datalogger extends Backbone.Model

class Webdlmon.Collections.Dataloggers extends Backbone.Collection
  model: Webdlmon.Models.Datalogger

# This is a dedicated parser class for the classic orbdlstat2xml2json
# stream that is currently spit out by the ANF web site
class Webdlmon.Collections.Orbdlstat2xmljson extends Webdlmon.Collections.Dataloggers
  parse: (response,xhr) ->
    result = []
    jQuery.each response.dataloggers, (dlname, props) ->
      props.values.id=dlname
      result.push(props.values)

    result

class Webdlmon.Models.Station extends Backbone.Model

class Webdlmon.Collections.Stations extends Backbone.Collection
  model: Webdlmon.Models.Station

  comparator: (a,b) ->
    statusOrder =
      active: 1
      adopt: 2
      decom: 3

    if a.get('status') == b.get('status')
      a.get('id') - b.get('id')
    else
      statusOrder[a.get('status')] - statusOrder[b.get('status')]

# Dedicated parser class for the db2json static file spit out by the
# ANF web site
class Webdlmon.Collections.Db2jsonStations extends Webdlmon.Collections.Stations
  parse: (response,xhr) ->
    result = []

    # parse active,adopt,decom objects returned in this feed
    jQuery.each response, (status,stations) ->
      jQuery.each stations, (sta, props) ->
        props.sta=sta
        props.id="#{props.snet}_#{sta}"
        # Put the station's active/adopt/decom into props
        props.status=status
        result.push(props)

    result

class Webdlmon.Views.DataloggersIndex extends Backbone.View
  initialize: (@el) ->
    @collection.on 'reset', @render, @

  showFields: ['con','gp1','gp24']
  render: ->
    @$el.html "<table id=\"webdlmon\"><thead><tr><th id=\"dlname\" class=\"header\">dlname</th></tr></thead><tbody id=\"webdlmon\"></tbody></table>"
    @collection.forEach (dl) =>
      view = new Webdlmon.Views.DataloggerRow
        model: dl
        showFields: @showFields
      @$('tbody#webdlmon').append view.render().el
    this

class Webdlmon.Views.DataloggerRow extends Backbone.View
  className: "dlrow"
  tagName: "tr"

  initialize: (options) ->
    @showFields = options.showFields

  render: ->
    # dlname
    $(@el).html "<td>#{@model.id}</td>"
    this

class Webdlmon.Routers.Dataloggers extends Backbone.Router
  routes:
    '': 'index'

  index: ->
    dls = new Webdlmon.Collections.Orbdlstat2xmljson
    dls.url='fixtures/webdlmon.json'

    stas = new Webdlmon.Collections.Db2jsonStations
    stas.url = 'fixtures/stations.json'

    view = new Webdlmon.Views.DataloggersIndex
      collection: dls
      el: '#app'

    dls.fetch()
    stas.fetch()

$ ->
  app=new Webdlmon
