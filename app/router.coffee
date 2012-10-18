define [
  # Application
  "app"
], (app) ->

  # Defining the application router,
  # you can attache sub routers here.
  Router = Backbone.Router.extend
    routes:
      "": "index"

    index: ->

  return Router
