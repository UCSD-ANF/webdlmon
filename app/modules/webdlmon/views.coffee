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
      for field in app.showFields
        val=@model.get field
        txt=Utils.formatDl field, val
        sort=Utils.sortorder field, val
        color=Utils.colorize field, val
        vals.push( [txt, sort, color] )
      return {
        "dlname": @model.get('dlname')
        "color" : Utils.colorize('con', @model.get('con'))
        "vals"  : vals
      }

  return Views
