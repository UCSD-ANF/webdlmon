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

    graph: (dlname, field) ->
      console.log "Route 'dataloggers/#{dlname}/graph/#{field}' matched to 'graph'"

    index: ->
      dlsFactory = new Webdlmon.DataloggersFactory
      dataloggers = dlsFactory.makeDataloggers app.dataloggersfeed.type
      dataloggers.url=app.dataloggersfeed.url

      stationsFactory = new Webdlmon.StationsFactory
      stations = stationsFactory.makeStations app.stationsfeed.type
      stations.url=app.stationsfeed.url

      # Use the main layout
      app.useLayout("main")

      # Insert the dltable
      mainTableView = app.layout.setView "#dltable", new Webdlmon.Views.DlTable

      # Set the first child view of the main table
      mainTableView.setView new Webdlmon.Views.Thead

      # Append the table body
      mainTableView.setView new Webdlmon.Views.Tbody({collection: dataloggers}),
        true

      # Insert the Legend
      app.layout.setView "#webdlmon-legend", new Webdlmon.Views.DlmonLegend

      app.layout.render()

      # Fetch the data
      dataloggers.fetch()
      stations.fetch()

  return Router
