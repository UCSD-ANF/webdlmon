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

    initialize: (options) ->
      dlsFactory = new Webdlmon.DataloggersFactory
      app.dataloggers = dlsFactory.makeDataloggers app.dataloggersfeed.type
      app.dataloggers.url=app.dataloggersfeed.url

      stationsFactory = new Webdlmon.StationsFactory
      app.stations = stationsFactory.makeStations app.stationsfeed.type
      app.stations.url=app.stationsfeed.url

      # Fetch the data
      app.dataloggers.fetch()
      app.stations.fetch()

    graph: (dlname, field) ->
      console.log "Route 'dataloggers/#{dlname}/graph/#{field}' matched to 'graph'"
      app.useLayout "graph"

      #dlmodels = app.dataloggers.where({dlname: dlname})
      #dlmodel=(_ dlmodels).first()
      graphshowview = app.layout.setView "#graphplot",
        new Webdlmon.Views.GraphShow
          dlname: dlname
          chan: field
          #model: dlmodel

      app.layout.render()


    index: ->

      # Use the main layout
      app.useLayout "main"

      # Insert the dltable
      mainTableView = app.layout.setView "#dltable", new Webdlmon.Views.DlTable

      # Set the first child view of the main table
      mainTableView.setView new Webdlmon.Views.Thead

      # Append the table body
      mainTableView.setView new Webdlmon.Views.Tbody({collection: app.dataloggers}),
        true

      # Insert the Legend
      app.layout.setView "#webdlmon-legend", new Webdlmon.Views.DlmonLegend

      app.layout.render()

  return Router
