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
        url: "http://anf.ucsd.edu/tools/webdlmon/data.php?callback=?"

      stations = new Webdlmon.Db2jsonStations
        url: "http://anf.ucsd.edu/stations/data.php?callback=?"

      app.useLayout("main")
      app.layout.render()

      # Fetch the data
      dataloggers.fetch
      stations.fetch

  return Router
