define [
  # Libraries.
  "jquery"
  "lodash"
  "backbone"

  # Plugins.
  "plugins/backbone.layoutmanager"
], ($, _, Backbone) ->

  # Provide a global location to place configuration settings and
  # module creation
  app =
    # The root path to run the application.
    root: "/~davis/dlmon/"

  # Localize or create a new JavaScript Template object.
  JST = window.JST = window.JST || {}

  # Configure Layout Manager with Backbone Boilerplate defaults.
  Backbone.LayoutManager.configure
    # Allow LayoutManager to augment Backbone.View.prototype.
    manage: true

    paths:
      layout: "app/templates/layouts/"
      template: "app/templates/"

    fetch: (path) ->
      # Concatenate the file extension.
      path = "#{path}.html"

      # If cached, use the compiled template.
      if JST[path]
        return JST[path]
      else
        # Put fetch into 'async-mode'.
        done = @async()

        # Seek out the template asynchronously.
        return $.ajax( url: app.root + path ).then (contents) ->
          done( JST[path] = _.template(contents) )
          return

  # Mix Backbone.Events, modules, and layout management into the app
  # object
  return _.extend app, {
    # Create a custom object with a nested Views object.
    module: (additionalProps) ->
      return _.extend { Views: {} }, additionalProps

    # Helper for using layouts.
    useLayout: (name, options) ->
      # If already using this Layout, then don't re-inject into the
      # DOM.
      return @layout if @layout && @layout.options.template == name

      # If a layout already exists, remove it from the DOM.
      @layout.remove if @layout

      # Create a new Layout with options.
      layout = new Backbone.Layout _.extend
        template: name
        className: "layout #{name}"
        id: "layout"
      , options

      # Insert into the DOM.
      $("#main").empty().append(layout.el)

      # Render the layout.
      layout.render

      # Cache the reference.
      @layout = layout

      # Return the reference, for chainability
      return layout
  }, Backbone.Events
