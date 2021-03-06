define [
  "app"

  # Libs
  "jquery.tablesorter"
  "backbone"

  # Utils
  "modules/webdlmon/utils"
], (app, TableSorter, Backbone, Utils) ->

  Views = {}

  class Views.DlTable extends Backbone.View
    tagName: "table"
    className: "tablesorter"
    id: "webdlmon"

    constructor: (options) ->
      @tablesorter_injected = false
      super options

    afterRender: ->
      if @tablesorter_injected
        @$el.trigger("update")
      else
        @$el.tablesorter()
        @tablesorter_injected = true

  class Views.Thead extends Backbone.View
    tagName: "thead"
    template: 'webdlmon/thead'

    serialize: ->
      # Map the displayed names of the fields that we are to show

      sds=app.station_status_defs
      fields=app.showFields

      res=fields.map (field) ->
        sd = {}
        sd = sds[field] if sds[field]?
        sd=(_ sd).defaults({title: field, description: field})
        sd=(_ sd).pick('title','description')
        return sd

      return {
        "showFields": res
      }

  class Views.DlmonLegend extends Backbone.View
    template: "webdlmon/legend"

    serialize: ->
      fields=app.showFields
      sds=app.station_status_defs

      res=fields.map (field) ->
        sd = {}
        sd = sds[field] if sds[field]?
        sd=(_ sd).defaults({title: field, description: field})
        sd=(_ sd).pick('title','description')
        sd.description=Utils.nl2br sd.description
        return sd
      return {
        fields: res
      }


  class Views.Tbody extends Backbone.View
    tagName: "tbody"
    initialize: ->
      @.listenTo @collection, 'reset', @render
      @.listenTo @collection, 'add', @addOne

    beforeRender: ->
      console.log "Views.Tbody.beforeRender called"
      @addAll()

    afterRender: ->
      # Trigger the jQuery event "update" on the current element
      # This will propogate upwards through the DOM to the parent table
      # element which may have a jquery.tablesorter attached to it.
      @$el.trigger("update")

    addAll: ->
      @collection.each @addOne, @
      return @

    addOne: (model) ->
      view = new Views.DataloggerRow
        model: model
      #view.render()
      @insertView view, @
      return @

  class Views.DataloggerRow extends Backbone.View
    className: "dlrow"
    tagName:   "tr"
    template:  "webdlmon/dlrow"

    initialize: ->
      @.listenTo @model, 'change', @.render
      @.listenTo @model, 'destroy', @.remove
      @.listenTo @model, 'remove', @.remove

    beforeRender: ->
      console.log "Rendering view %s", @model.id

    serialize: ->
      vals = []
      # Handle dlname explicitly since we always want it to appear
      #vals.push @formatize 'dlname'

      # Loop through showFields and format the values we need
      vals.push @formatize(fieldName) for fieldName in app.showFields

      # return the data for use by the template
      return {
        "vals"  : vals
      }

    # Return a tuple of [ formattedText, sortValue, color ]
    formatize: (fieldName) ->
      extracted=@model.toJSON()
      txt = Utils.formatDl fieldName, extracted
      sort = Utils.sortorder fieldName, extracted
      color = Utils.colorize fieldName, extracted
      graph = Utils.hasgraph fieldName
      res =
        id: @model.id
        field: fieldName
        txt: txt
        sort: sort
        color: color
        graph: graph
      return res

    remove: ->
      console.log "Removing view %s", @model.id
      super()

  class Views.GraphShow extends Backbone.View
    template: "webdlmon/graphshow"
    events:
      'click .twin.prev': 'prevTimeWindow'
      'click .twin.next': 'nextTimeWindow'

    initialize: (options) ->
      @apiurl = options["apiurl"] ? app.graphapiurl

      @model.bind 'change', @.render, @
      @ # return "this" for chaining

    getNetSta: ->
      dlname = @model.get 'dlname'
      [net, sta] = dlname.split '_'
      console.log "Views.Graphshow Net:"+net+" Sta:"+sta, dlname
      [net, sta]

    serialize: ->
      [net, sta] = @getNetSta()
      return {
        apibase: @apiurl
        net: net
        sta: sta
        chan: @model.get 'chan'
        twin: @model.get 'timeWindow'
      }

    nextTimeWindow: ->
      @model.nextTimeWindow()

    prevTimeWindow: ->
      @model.prevTimeWindow()

  class Views.GraphDescription extends Backbone.View
    template: "webdlmon/graphdescription"

    initialize: (options) ->
      @model.bind 'change', @render, @
      @

    serialize: ->
      return {
        dlname: @model.get 'dlname'
        chan: @model.get 'chan'
        timeWindow: @model.get 'timeWindow'
      }

  return Views
