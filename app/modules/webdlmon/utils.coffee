define [
  "app"

  # Libs
  "backbone"
  "underscore.string"
], ( app, Backbone, _s ) ->

  Utils =
  
  
    # Util.sortorder
    # --------------
    # Returns a value to use for sorting based on a datalogger status
    # field name
    sortorder : (fieldName, dlValues) ->
      # Look for a sortorderer with the same name as our fieldName
      return @sortorderers[fieldName](fieldName, dlValues) if @sortorderers[fieldName]?
      
      # If we don't have an explicitly named sortorderer for the fieldName,
      # use this lookup table
      #switch fieldname

      return dlValues[fieldName]?
  
    # sorting procedures for the datalogger model collection
    # key is the name of the field that we are sorting, 
    # "dlValues" is the serialized form of a datalogger model, which
    # usually looks something like:
    # {
    #   id: TA_123A
    #   con: su
    #   rtm: -3700.0
    # }
    
    sortorderers :
      
      dlname: (keyName, dlValues) ->
        # mimics the original procedure used in dlmon rather than the
        # XSLT webdlmon method
        runstat = dlValues.con
        sortorder = 1 # default value
        if runstat?
          if ( runstat == "no" && dlValues.rtm > -3600.0)
            runstat = "su"
            dlValues[con] = runstat
          sortorder = Utils.sortorder "con", dlValues
        return sortorder


      con : (keyName, dlValues) ->
        # Convert Datalogger connection state to numeric sort priority
        # Ignore the key provided
        switch dlValues.con
          when "yes","waiting"
            return 4
          when "su","reg","sleeping","hibernating","no"
            return 1
          when "stopped"
            return 0
          else
            return 1

    # Util.colorize
    # -------------
    colorize: (fieldName, dlValues) ->
      # Look for a colorizer with the same name as our fieldName
      return @colorizers[fieldName](fieldName, dlValues) if @colorizers[fieldName]
      
      # If we don't have an explicitly named colorizer for the fieldName,
      # use this lookup table
      switch fieldName
        when "dlname"
          return @colorizers.con fieldName, dlValues
        when "gp1","gp24"
          return @colorizers.gp fieldName, dlValues
        when "nr24"
          return @colorizers.nr fieldName, dlValues
        when "nl24", "np24"
          return @colorizers.nlnp fieldName, dlValues
        when 'br24', 'bw24'
          return @colorizers.brw24 fieldName, dlValues
        else
        # No default color
          return null

    colorizers :
      con: (fieldName, dlValues) ->
        color=null
        value = dlValues.con # ignore fieldname
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

      gp: (fieldName, dlValues) ->
        color=null
        if dlValues[fieldName] != '-'
          value=parseInt value,10
          if value >= 60
            color="#ff0000"
          else if value > 0
            color="#ffff00"
          else
            color="#d0d0ff"
        return color

      nr: (fieldName, dlValues) ->
        color=null
        if dlValues[fieldName] != '-'
          if dlValues[fieldName] > 0.0
            color = "#ff0000"
          else
            color = "#d0d0ff"
        return color

      acok: (fieldName, dlValues) ->
        color = "#ffff00"
        value = dlValues[fieldName]
        if (value != undefined)
          value=parseInt value, 10
          if !isNaN value
            if value >=1
              color = "#00ff00"
            else if value = 0
              color = "#ff0000"
        return color
        
      dlt: (fieldName, dlValues) ->
        # Data latency formatter
        value = dlValues[fieldName]
        con = dlValues.con
        color=''
        if value != '-'
          color = '#d0d0ff'
          if con == 'waiting'
            if value >= 3*60
              color = '#ff0000'
            else if value >= 2*60
              color = '#ff8000'
            else if value >= 1*60
              color = '#ffff00'
            else
              color = '#a0ffa0'
          else
            color = '#c0ffc0' if value >=60
            color = '#ffff00' if value >= 3600
            color = '#ff0000' if value >= 3*3600 # 3 hours
            # Highlight dataloggers with negative latency (timing problems)
            color = '#ff0000' if value < 0
        return color
        
      rtm: (fieldName, dlValues) ->
        value = dlValues[fieldName]
        con = dlValues.con
        color=''
        if value != '-'
          value = parseInt(value,10)
          color = '#d0d0ff'
          
          if value >= 0.0
            color = '#d0d0ff'
          else if con == 'waiting'
            if value >= 3*60
              color = '$ff0000'
            else if value >= 2*60
              color = '$ff8000'
            else if value >= 1*60
              color = '#ffff00'
          else
            if ( con == 'su' || con =='no') && value > -3600
              color = '#ffa0a0'
            else if con == 'yes' && value < 0
              color = '#ffa0a0'
            else
              color = '#ff0000'
        return color
        
      tput: (fieldName, dlValues) ->
        color=''
        value=dlValues[fieldName]
        con = dlValues.con
        if value != '-'
          if con == 'waiting'
            color = '#d0ffd0'
          else if con == 'su'
            color = '#d0ffd0'
          else if value == 'inf'
            color = '#ff0000'
          else
            if value <= 0.5
              color = '#ffa0a0'
            else if value <= 0.8
              color = '#ff80a0'
            else if value <= 0.9
              color = '#ffffa0'
            else if value < 1.1
              color = '#d0ffd0'
            else
              color = '#d0d0ff'

        return color
        
      clt: (fieldName, dlValues) ->
        color = ''
        value = dlValues[fieldName]
        if value != '-'
          if value >= 24*3600 # 24 days
            color = '#ffff00'
          else if value >= 6*3600 # six days
            color = '#ffff00'
          else if value > 3600 # 1 day
            color = '#c0ffc0'
          else color = '#d0d0ff'
        return color
        
      ce: (fieldName, dlValues) ->
        value = dlValues[fieldName]
        con = dlValues.con
        color = ''
        if value != '-'
          if value == 'inf'
            color = '#ff0000'
          else
            if con == 'waiting'
              color = '#a0ffa0'
            else if con == 'su'
              color = '#ffa0a0'
            else if value <= 10.0
              color = '#ff0000'
            else if value <= 50.0
              color = '#ffff00'
            else if value < 90.0
              color = '#d0ffd0'
            else color = '#d0d0ff'
        return color
        
      pbr: (fieldName, dlValues) ->
        color=''
        value = dlValues[fieldName]
        if value != '-'
          if value == 'inf'
            color = '#ff0000'
          else
            if value <= 1.0
              color = '#d0d0ff'
            else if value < 10.0
              color = '#a0ffa0'
            else if value < 50.0
              color = '#ffff00'
            else
              color = '#ff0000'
        return color
        
      nlnp: (fieldName, dlValues) ->
        color = ''
        value = dlValues[fieldName]
        if value != '-'
          if value >= 500.0
            color = '#ff0000'
          else if value >= 200.0
            color = '#ffff00'
          else if value >= 20.0
            color = '#d0ffd0'
          else
            color = '#d0d0ff'
        return color
      
      ni24: (fieldName, dlValues) ->
        color = ''
        value = dlValues[fieldName]
        if value != '-'
          if value >= 10.0
            color = '#ff0000'
          else if value >= 5.0
            color = '#ff8000'
          else if value > 1.0
            color = '#ffff00'
          else color = '#d0d0ff'
        return color
        
      brw24: (fieldName, dlValues) ->
        color = ''
        value = dlValues[fieldName]
        if value != '-'
          color='#d0d0ff'
        return color
    
    # master channel value formatter
    # --------------------------------
    formatDl: (fieldName, dlValues) ->
      return @formatters[fieldName](fieldName, dlValues) if @formatters[fieldName]?
      
      # Lookup table for fieldnames without a dedicated formatter
      switch fieldName
        when "gp1","gp24"
          return @formatters.gp fieldName, dlValues
        when "nr24"
          return @formatters.nr fieldName, dlValues
        when "dlt", "rtm", "clt"
          return @formatters.dhms fieldName, dlValues
        when 'ce', 'pbr', 'lcq'
          return @formatters.percentage fieldName, dlValues
        when 'nl24', 'np24', 'ni24'
          return @formatters.nlnpni fieldName, dlValues
        when 'dr','br24','bw24'
          return @formatters.bytes fieldName, dlValues
        else
          return dlValues[fieldName]

    # channel value formatters
    # ------------------------
    formatters:
      gp: (fieldName, dlValues) ->
        txt="" # default return value
        value = dlValues[fieldName]
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

      nr: (fieldName, dlValues) ->
        txt='' # default return value
        value = dlValues[fieldName]
        if(value != '-')
          value = parseInt value, 10
          txt = _s.sprintf "%.0f", value
        return txt

      acok: (fieldName, dlValues) ->
        txt = "-" # default return value
        value = dlValues[fieldName]
        if value?
          value=parseInt(value)
          if !isNaN value
            if value >= 1
              txt = "1"
            else if value = 0
              txt = "0"
        return txt
        
      dhms: (fieldName, dlValues) ->
        value = dlValues[fieldName]
        if value? && value != '-'
          [d, h, m, s, sign] = Utils.get_dhms value
          return Utils.format_dhms d,h,m,s,sign
          
      tput: (fieldName, dlValues) ->
        value = dlValues[fieldName]
        txt=''
        if value == 'inf'
          txt = 'inf'
        else
          txt = _s.sprintf '%.2f', +value
        return txt
        
      percentage: (fieldName, dlValues) ->
        txt = '-'
        value = dlValues[fieldName]
        if value? && value != '-'
          txt = _s.sprintf '%d%%', +value
        return txt
        
      nlnpni: (fieldName, dlValues) ->
        value=dlValues[fieldName]
        txt = ''
        if value != '-'
          txt = _s.sprintf '%d', +value
        return txt
        
      bytes: (fieldName, dlValues) ->
        # Bytes read/written
        # dlmon was using powers of 10 for formatting
        # Maybe this should be powers of 8?
        value = dlValues[fieldName]
        txt = ''
        if value != '-'
          value = parseInt(value)
          if value >= Math.pow(10,10)
            txt = _s.sprintf '%dg', value/Math.pow(10,9)
          else if value >= Math.pow(10,9)
            txt = _s.sprintf '%.1fg', value/Math.pow(10,9)
          else if value >= Math.pow(10,7)
            txt = _s.sprintf '%dm', value/Math.pow(10,6)
          else if value >= Math.pow(10,6)
            txt = _s.sprintf '%.1fm', value/Math.pow(10,6)
          else if value >= Math.pow(10,4)
            txt = _s.sprintf '%dk', value/Math.pow(10,3)
          else if value >= Math.pow(10,3)
            txt = _s.sprintf '%.1fk', value/Math.pow(10,3)
          else
            txt = _s.sprintf '%d', value
        return txt

    # Takes a time in minutes
    # Returns an array of time in days, hours, minutes, seconds [, sign]
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
        aval -= m*60
      s = aval
      if minutes < 0
        sign = "-"
      else sign = "+"
      return [d,h,m,s, sign]

    format_dhms: (d=0,h=0,m=0,s=0,sign="+") ->
      if sign != '-'
        sign = ''
      if( d > 0 )
        txt = _s.vsprintf "%s%3dd%2.2dh%2.2dm%2.2ds", [sign, d, h, m, s]
      else if ( h > 0)
        txt = _s.vsprintf "    %s%2.2dh%2.2dm%2.2ds", [sign,h, m, s]
      else if ( m > 0)
        txt = _s.vsprintf "       %s%2.2dm%2.2ds", [sign, m, s]
      else
        txt = _s.vsprintf "          %s%2.2ds", [sign, s]
      return txt

  return Utils
