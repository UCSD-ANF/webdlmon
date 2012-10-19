define [
  "app"

  # Libs
  "backbone"
], (app, Backbone) ->

  Views = {}

  class Views.Thead extends Backbone.View
    template: 'webdlmon/thead'

    serialize: ->
      return {
        "showFields": app.showFields
      }

  class Views.Tbody extends Backbone.View
    className: "foo"

    initialize: ->
      @collection.on 'reset', @render, @

    # Rendering function
    #render: (manage) ->
    #  @collection.forEach (item) ->
    #    @insertView new Views.DataloggerRow
    #      model: item
    #  return manage(this).render()

    beforeRender: ->
      @collection.each (thingy) ->
        @insertView new Views.DataloggerRow
          model: thingy
      , @

  class Views.DataloggerRow extends Backbone.View
    className: "dlrow"
    tagName:   "tr"
    template:  "webdlmon/dlrow"

    initialize: ->
      @model.on "change", ->
        @render()
      , @

      @model.on "destroy", ->
        @remove()
      , @

    serialize: ->
      vals = []
      # Loop through showFields and extract the values we need
      vals.push @model.get field for field in app.showFields
      return {
        "id": @model.id
        "vals": vals
      }

  return Views
