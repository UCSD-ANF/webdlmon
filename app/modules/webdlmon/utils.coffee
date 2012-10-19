define [
  "app"

  # Libs
  "backbone"
  "underscore.string"
], ( app, Backbone, _s ) ->

  Utils =

    # sorting procedure for the dataloggers collection
    # mimics the original procedure used in dlmon rather than the
    # original webdlmon method via XSLT
    # "datalogger" is the serialized form of a datalogger model, which
    # usually looks something like:
    # {
    #   id: TA_123A
    #   con: su
    #   rtm: -3700.0
    # }
    dlc_sortorder: (datalogger) ->
      runstat = datalogger.con
      sortorder = 1
      if runstat?
        if ( runstat == "no" && datalogger.rtm > -3600.0)
          runstat = "su"
        sortorder=@sortorder_con(runstat)
      return sortorder


    # Datalogger Connection state to numeric sort priority
    sortorder_con : (con) ->
      switch con
        when "yes","waiting"
          return 4
        when "su","reg","sleeping","hibernating","no"
          return 1
        when "stopped"
          return 0
        else
          return 1

    # Util.sortorder
    # --------------
    # Returns a value to use for sorting based on a datalogger status
    # field name
    sortorder : (fieldname, value) ->
      switch fieldname
        when "con"
          return @sortorder_con value
        else
          # Default case: return the raw value if any
          return value? value : 0

    # Util.colorize
    # -------------
    colorize: (fieldname, value) ->
      switch fieldname
        when "con"
          return @color_con value
        when "gp1","gp24"
          return @color_gp value
        #else
        # No default color
        #  return "#e0e0e0"

    color_con: (value) ->
      color=null
      if value != '-'
        switch value
          when "stopped"
            color = "#808080"
          when "yes"
            color = "#00ff00"
          when "waiting"
            color = "#00ffff"
          when "hibernating"
            color = "#ff00ff"
          when "sleeping"
            color = "#ff0000"
          when "reg"
            color = "#ffd000"
          when "su"
            color = "#ffa000"
          when "nr"
            color = "#ffa0a0"
          else
            color = "#ff0000"
        return color

    color_gp: (value) ->
      color=null
      if value != '-'
        value=parseInt value,10
        if value >= 60
          color="#ff0000"
        else if value > 0
          color="#ffff00"
        else
          color="#d0d0ff"
      return color

    formatDl: (fieldname, value) ->
      switch fieldname
        when "gp1","gp24"
          return @formatdl_gp value
        else
          return value ? ""

    formatdl_gp: (value) ->
      txt=""
      if value != "-"
        value = parseInt value,10
        if value >= 86400
          txt = _s.sprintf "%.0fd", value/86400.0
        else if value >= 3600
          txt = _s.sprintf "%.0fh", value/3600.0
        else if value >= 60
          txt = _s.sprintf "%.0fm", value/60.0
        else if value > 0
          txt = _s.sprintf "%.0fs", value
        else
          txt = "0s"
      return txt

    # Takes a time in minutes
    # Returns an array of time in days, hours, minutes, seconds
    get_dhms: (minutes) ->
      aval = Math.abs(minutes)
      if (aval >= 86400)
        d = Math.floor(aval/86400)
        aval -= d*86400
      if (aval >= 3600)
        h = Math.floor(aval/3600)
        aval -= h*3600
      if (aval >= 60)
        m = Math.floor(aval/60)
        aval -= h*60
      s = aval
      return [d,h,m,s]

    format_dhms: (d,h,m,s) ->
      if( d > 0 )
        txt = _s.vsprintf "%3dd%2.2dh%2.2dm%2.2ds", [d, h, m, s]
      else if ( h > 0)
        txt = _s.vsprintf "    %2.2dh%2.2dm%2.2ds", [h, m, s]
      else if ( m > 0)
        txt = _s.vsprintf "       %2.2dm%2.2ds", [m, s]
      else
        txt = _s.sprintf "          %2.2ds", s
      return txt

  return Utils
