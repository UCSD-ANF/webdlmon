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
    constructor: (models, options)->
      @type = "Orbdlstat2xmljson Dataloggers feed"
      super models, options

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
  class Webdlmon.DlmonDataloggers extends Webdlmon.Dataloggers
    constructor: (models, options)->
      @type = "Dlmon Dataloggers feed"
      super models, options

    parse: (response, xhr) ->
      parsed = response.dataloggers.map (props) ->
        mapres = props.values
        mapres.dlname = props.name
        return mapres
        
      return parsed

  # DataloggersFactory
  # ------------------
  # Allow run-time selection of the Dataloggers type
  class Webdlmon.DataloggersFactory
    makeDataloggers: (type, models, options) ->
      switch type
        when "dlmon" then new Webdlmon.DlmonDataloggers models, options
        when "orbdlstat2xmljson" then new Webdlmon.Orbdlstat2xmljson models, options
        else new Webdlmon.Dataloggers models, options

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
    constructor: (models, options) ->
      @type = "Db2json Stations"
      super models, options

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

  # StationsFactory
  # ---------------
  # Allow run-time selection of Stations subclass
  class Webdlmon.StationsFactory
    makeStations: (type, models, options) ->
      switch type
        when "db2json" then new Webdlmon.Db2jsonStations models, options
        else new Webdlmon.Stations models, options

  # Grapher
  # -------
  # Model the internal state of the graph viewer sub-application
  class Webdlmon.Grapher extends Backbone.Model
    defaults:
      timeWindow: 'w'
      
    _valid_twins: ['h', 'd', 'w', 'm', 'y', 'lifetime']

    _validate_timeWindow: (twin) ->
      unless twin in @valid_twins
        console.log "Invalid twin, must be one of" + @_valid_twins.join(", ")
        return false
      return true

    initialize: (options) ->
      _.bindAll @, 'nextTimeWindow', 'prevTimeWindow'
      @dlname = options.dlname
      @chan = options.chan
      #@dataloggers = @options.dataloggers
      
    currentTimeWindow: ->
      return @timeWindow

    isLastTimeWindow: (twin) ->
      currentTwinIndex = @_valid_twins.indexOf twin
      return currentTwinIndex >= (@_valid_twins.length - 1)

    isFirstTimeWindow: (twin) ->
      currentTwinIndex = @_valid_twins.indexOf twin
      return currentTwinIndex == 0

    nextTimeWindow: ->
      currentTwin = @.get 'timeWindow'
      currentTwinIndex = @_valid_twins.indexOf currentTwin
      console.log "nextTimeWindow: Old " + @.get 'timeWindow'
      if @isLastTimeWindow currentTwin
        currentTwinIndex = 0
      else
        currentTwinIndex++
      @.set 'timeWindow', @_valid_twins[currentTwinIndex]
      console.log "nextTimeWindow: New " + @.get 'timeWindow'
      @
      
    prevTimeWindow: ->
      currentTwin = @.get 'timeWindow'
      currentTwinIndex = @_valid_twins.indexOf currentTwin
      if @isFirstTimeWindow currentTwin
        currentTwinIndex = @_valid_twins.length - 1
      else
        currentTwinIndex--
      @.set 'timeWindow', @_valid_twins[currentTwinIndex]
      console.log "prevTimeWindow: Old " + currentTwin + " New " + @.get 'timeWindow'
      @

  # Webdlmon Views
  # --------------

  # Attach the Views sub-module into this module.
  Webdlmon.Views = Views

  # Required, return the module for AMD compliance.
  return Webdlmon
