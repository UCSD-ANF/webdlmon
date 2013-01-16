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
      @collection.on 'reset', @render, @

    beforeRender: ->
      @collection.each (model) ->
        @insertView new Views.DataloggerRow
          model: model
      , @

    afterRender: ->
      # Trigger the jQuery event "update" on the current element
      # This will propogate upwards through the DOM to the parent table
      # element which may have a jquery.tablesorter attached to it.
      @$el.trigger("update")

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
        id: @model.get "dlname"
        field: fieldName
        txt: txt
        sort: sort
        color: color
        graph: graph
      return res

  class Views.GraphShow extends Backbone.View
    # TODO: This implementation breaks the Model/View separation in a big way.
    # The view is tracking the dlname since the graphing API has no need for
    # any of the other information in the datalogger model, and we can't
    # always assume that we have loaded the dataloggerCollection from the AJAX
    # call if this is the first load of the application.
    # Perhaps a better approach is to instantiate a model just for this view,
    # and allow it to reference the datalogger model as a property.
    template: "webdlmon/graphshow"

    _default_twin: 'w'
    _default_dlname: "ZZ_ZZZZ"

    _validate_twin: (twin) ->
      valid_twins = ['h', 'd', 'w', 'm', 'lifetime']
      unless twin in valid_twins
        console.log "Invalid twin, must be one of" . valid_twins.join(", ")
        return false
      return true

    initialize: (options) ->
      @apiurl = options["apiurl"] ? app.graphapiurl
      @chan = options["chan"] ? "da"

      twin = options["twin"] ? @_default_twin
      @set_twin twin

      dlname = options["dlname"] ? @_default_dlname
      @set_dlname dlname
      @ # return "this" for chaining

    set_twin: (twin) ->
      @_validate_twin twin or twin = @_default_twin
      @twin=twin
      @

    set_dlname: (dlname) ->
      @dlname=dlname
      [@net, @sta] = dlname.split("_")

    serialize: ->
      return {
        apibase: @apiurl
        net: @net
        sta: @sta
        chan: @chan
        twin: @twin
      }

  return Views
