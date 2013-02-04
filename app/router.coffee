define [
  # Application.
  "app"

  # Modules.
  "modules/webdlmon"
], (app, Webdlmon) ->

  # Defining the application router,
  # you can attach sub routers here.
  Router = Backbone.Router.extend
    routes:
      'dataloggers/:dlname/graph/:field' : 'graph'
      "": "index"
      
    updateInterval: 30 # default interval for long poll

    initialize: (options) ->
      @updateInterval = options.updateInterval if options.updateInterval?
      
      dlsFactory = new Webdlmon.DataloggersFactory
      app.dataloggers = dlsFactory.makeDataloggers options.dataloggersFeed.type
      app.dataloggers.url=options.dataloggersFeed.url

      stationsFactory = new Webdlmon.StationsFactory
      app.stations = stationsFactory.makeStations options.stationsFeed.type
      app.stations.url=options.stationsFeed.url

      # Perform the initial fetch of the collections
      app.dataloggers.fetch()
      app.stations.fetch()

      # Set up a long-poll of the dataloggers collection
      app.dataloggersUpdateIntervalId = setInterval @dlLongPoll,
      @updateInterval * 1000 # convert ms to seconds

    dlLongPoll: ->
      console.log "firing dlLongPoll"
      app.dataloggers.fetch
        update: true
        #remove: false

    graph: (dlname, field) ->
      console.log "Route 'dataloggers/#{dlname}/graph/#{field}' matched to 'graph'"
      app.useLayout "graph"

      #dlmodels = app.dataloggers.where({dlname: dlname})
      #dlmodel=(_ dlmodels).first()
      
      # Set up the grapher
      grapher = new Webdlmon.Grapher
        dlname: dlname
        chan: field
      
      graphshowview = app.layout.setView "#graphplot",
        new Webdlmon.Views.GraphShow
          model: grapher

      app.layout.setView "#graphdescription",
        new Webdlmon.Views.GraphDescription
          model: grapher

      app.layout.render()


    index: ->

      # Use the main layout
      app.useLayout "main"

      # Insert the dltable
      dltable = app.layout.setView "#dltable", new Webdlmon.Views.DlTable
      
      # Set the first child view of the main table
      dltable.setView new Webdlmon.Views.Thead

      # Append the table body
      dltable.setView new Webdlmon.Views.Tbody({collection: app.dataloggers}),
        true

      # Insert the Legend
      app.layout.setView "#webdlmon-legend", new Webdlmon.Views.DlmonLegend

      app.layout.render()

  return Router
