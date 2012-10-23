define [
  "app"

  # Libs
  "backbone"

  # Utils
  "modules/webdlmon/utils"
], (app, Backbone, Utils) ->

  Views = {}

  class Views.DlTable extends Backbone.View
    tagName: "table"
    className: "webdlmon"
    #template: 'webdlmon/dltable'

  class Views.Thead extends Backbone.View
    tagName: "thead"
    template: 'webdlmon/thead'

    serialize: ->
      return {
        "showFields": app.showFields
      }

  class Views.Tbody extends Backbone.View
    tagName: "tbody"
    initialize: ->
      @collection.on 'reset', @render, @

    beforeRender: ->
      @collection.each (model) ->
        @insertView new Views.DataloggerRow
          model: model
      , @

  class Views.DataloggerRow extends Backbone.View
    className: "dlrow"
    tagName:   "tr"
    template:  "webdlmon/dlrow"

    initialize: ->
      @model.on "change", ->
        @render()
      , @ # return this object for chaining

      @model.on "destroy", ->
        @remove()
      , @ # return this object for chaining

    serialize: ->
      vals = []
      # Handle dlname explicitly since we always want it to appear
      vals.push @formatize 'dlname'
      
      # Loop through showFields and format the values we need
      vals.push @formatize(fieldName) for fieldName in app.showFields
      
      # return the data for use by the template
      return {
        "vals"  : vals
      }
      
    # Return a tuple of [ formattedText, sortValue, color ]
    formatize: (fieldName) ->
      extracted=@model.toJSON()
      return [
        Utils.formatDl fieldName, extracted
        Utils.sortorder fieldName, extracted
        Utils.colorize fieldName, extracted 
      ]

  return Views
