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

      stations = new Webdlmon.Db2jsonStations
      stations.url="http://anf.ucsd.edu/stations/data.php?callback=?"

      # Use the main layout
      app.useLayout("main").setViews
        # Attach the table header View to the layout.
        "thead": new Webdlmon.Views.Thead
          collection: dataloggers

        # Attach the table body View to the layout
        "tbody": new Webdlmon.Views.Tbody
          collection: dataloggers

      app.layout.render()

      # Fetch the data
      dataloggers.fetch()
      stations.fetch()

  return Router
