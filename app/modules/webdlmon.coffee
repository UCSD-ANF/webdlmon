define [
  "app"

  # Libs
  "backbone"

  # Views
  "modules/webdlmon/views"

  # Utility Functions
  "modules/webdlmon/utils"

], ( app, Backbone, Views, Utils ) ->

  # Create a new module
  Webdlmon = app.module

  # Datalogger Model
  # ----------------
  class Webdlmon.Datalogger extends Backbone.Model
    idAttribute = "dlname"

  # Dataloggers Collection
  # ----------------------
  class Webdlmon.Dataloggers extends Backbone.Collection
    model: Webdlmon.Datalogger
    comparator: (a) ->
      Utils.sortorder('dlname', a.toJSON() )

  # Orbdlstat2xmljson Dataloggers Collection
  # ------------------------
  # This is a dedicated parser class for the classic orbdlstat2xml2json
  # stream that is currently spit out by the ANF web site
  class Webdlmon.Orbdlstat2xmljson extends Webdlmon.Dataloggers
    parse: (response,xhr) ->
      # flatten returned dataloggers objects
      parsed = (_ response.dataloggers).map (props, dlname, list) ->
        mapres = props.values
        mapres.dlname=dlname
        return mapres
      return parsed

  # DlmonDataloggers
  # ----------------
  # This is a dedicated parser class for the new dlmon service being written
  # by Jeff Laughlin.
  class Webdlmon.DlmonDataloggers
    parse: (response, xhr) ->
      parsed = (_ response).map (props) ->
        mapres = props.values
        mapres.dlname = props.name
        return mapres
        
      return parsed

  # Station Model
  # -------------
  # Represents an entry in the stations database for the network.
  # Metadata for a Datalogger.
  class Webdlmon.Station extends Backbone.Model

  # Stations Collection
  # -------------------
  class Webdlmon.Stations extends Backbone.Collection
    model: Webdlmon.Station
    
    comparator: (a) ->
      statusOrder =
        active: 1
        adopt: 2
        decom: 3

      # Sort by status, then station id
      statusOrder[a.get 'status' ] + "_#{a.get 'id'}"

  # Db2json Stations Collection
  # ---------------------------
  # Dedicated parser class for the db2json static file spit out by the
  # ANF web site
  class Webdlmon.Db2jsonStations extends Webdlmon.Stations
    parse: (response,xhr) ->
      parsed = (_ response).map (status,stations) ->
        # Flatten the returned station for use by the Station model
        jQuery.each stations, (sta, props) ->
          # flatten sta into props object
          props.sta=sta
          # Synthetic id based on snet_sta to match the dlname
          props.id="#{props.snet}_#{sta}"
          # Put the station's active/adopt/decom into props
          props.status=status
          props
      parsed

  # Webdlmon Views
  # --------------

  # Attach the Views sub-module into this module.
  Webdlmon.Views = Views

  # Required, return the module for AMD compliance.
  return Webdlmon
