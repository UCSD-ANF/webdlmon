define [
  "app"

  # Libs
  "backbone"

  # Views
  "modules/webdlmon/views"
], ( app, Backbone, Views ) ->

  # Create a new module
  Webdlmon = app.module

  # Datalogger Model
  # ----------------
  class Webdlmon.Datalogger extends Backbone.Model

  # Dataloggers Collection
  # ----------------------
  class Webdlmon.Dataloggers extends Backbone.Collection
    constructor: (@url) ->
      #noop
    model: Webdlmon.Datalogger

  # Orbdlstat2xmljson Dataloggers Collection
  # ------------------------

  # This is a dedicated parser class for the classic orbdlstat2xml2json
  # stream that is currently spit out by the ANF web site
  class Webdlmon.Orbdlstat2xmljson extends Webdlmon.Dataloggers
    parse: (response,xhr) ->
      result = []
      jQuery.each response.dataloggers, (dlname, props) ->
        props.values.id=dlname
        result.push(props.values)

        result

  # Station Model
  # -------------
  # Represents an entry in the stations database for the network.
  # Metadata for a Datalogger.
  class Webdlmon.Station extends Backbone.Model

  # Stations Collection
  # -------------------
  class Webdlmon.Stations extends Backbone.Collection
    constructor: (@url) ->
      # noop
    model: Webdlmon.Station
    comparator: (a,b) ->
      statusOrder =
        active: 1
        adopt: 2
        decom: 3

      if a.get('status') == b.get('status')
        a.get('id') - b.get('id')
      else
        statusOrder[a.get('status')] - statusOrder[b.get('status')]

  # Db2json Stations Collection
  # ---------------------------
  # Dedicated parser class for the db2json static file spit out by the
  # ANF web site
  class Webdlmon.Db2jsonStations extends Webdlmon.Stations
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

  # Webdlmon Views
  # --------------

  # Attach the Views sub-module into this module.
  Webdlmon.Views = Views

  # Required, return the module for AMD compliance.
  return Webdlmon
