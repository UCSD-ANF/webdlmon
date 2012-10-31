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
      "": "index"

    index: ->
      dataloggers = new Webdlmon.Orbdlstat2xmljson
      dataloggers.url="http://anf.ucsd.edu/tools/webdlmon/data.php?callback=?"
      #dataloggers = new Webdlmon.DlmonDataloggers
      #dataloggers.url="http://anfdevl.ucsd.edu:7000/dlmon?callback=?"

      stations = new Webdlmon.Db2jsonStations
      stations.url="http://anf.ucsd.edu/stations/data.php?callback=?"

      # Use the main layout
      app.useLayout("main")
      mainTableView = app.layout.setView "#dltable", new Webdlmon.Views.DlTable

      # Set the first child view of the main table
      mainTableView.setView new Webdlmon.Views.Thead

      # Append the table body
      mainTableView.setView new Webdlmon.Views.Tbody({collection: dataloggers}),
        true

      app.layout.render()

      # Fetch the data
      dataloggers.fetch()
      stations.fetch()

  return Router
