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

      return dlValues[fieldName] if dlValues[fieldName]?
  
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
        sortorder = "1_#{dlValues[keyName]}" # default value
        if runstat?
          if ( runstat == "no" && dlValues.rtm > -3600.0)
            runstat = "su"
            dlValues[con] = runstat
          sortorder = Utils.sortorder "con", dlValues
          sortorder = "#{sortorder}_#{dlValues[keyName]}"
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
        when 'm0', 'm1', 'm2', 'm3', 'm4', 'm5'
          return @colorizers.massposition fieldName, dlValues
        when 'lat', 'lon', 'elev'
          return @colorizers.latlon fieldName, dlValues
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
        color = "#ffff00" #unknown
        value = dlValues[fieldName]
        if value?
          value=parseInt value
          if !(isNaN value)
            if value >=1
              color = "#00ff00" # good
            else if value == 0
              color = "#ff0000" # bad
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
      
      dr: (fieldName, dlValues) ->
        color = ''
        value = dlValues[fieldName]
        if value != '-'
          if value >= Math.pow(10,4)
            color='#d0d0ff'
          else if value >= 500
            color='#a0ffa0'
          else if value > 0
            color='#ffffa0'
          else color='#ffa0a0'
        return color
        
      brw24: (fieldName, dlValues) ->
        color = ''
        value = dlValues[fieldName]
        if value != '-'
          color='#d0d0ff'
        return color
        
      lcq: (fieldName, dlValues) ->
        color = ''
        value = dlValues[fieldName]
        if value != '-'
          if value == 'inf'
            color = '#ff0000'
          else
            color='#ff0000'
            if value >= 10.0 && value <= 60.0
              c = Math.floor( (63.0*(value-10.0)/50.5)+0.5 )
              color = _s.sprintf '#ff%2xd0', 192+c
            else if value > 60.0 && value < 90.0
              color = '#f0ffd0'
              if value < 80.0
                color = '#ffffd0'
            else if value >= 90.0
              if value < 95.0
                c = Math.floor( (63.0*(95.0-value)/5.0)+0.5)
                color = _s.sprintf '#d0ff%2x', 255-c
              else if value >= 95.0 && value < 100.0
                c = Math.floor((63.0*(100.0-value)/5.0)+0.5)
                color = _s.sprintf '#d0%2xff', 192+c
              else if value >= 100.0
                color = '#d0d0ff'
        return color
        
      cld: (fieldName, dlValues) ->
        color = ''
        value = dlValues[fieldName]
        if value != '-'
          aval = Math.abs value
          if aval > 5 * (Math.pow 10,3)
            color = '#ffd0d0'
          else if aval > 2 * (Math.pow 10,3)
            color = '#ffffd0'
          else if aval >= Math.pow(10,3)
            color = '#d0ffd0'
          else color = '#d0d0ff'
          
        return color
        
      massposition: (fieldName, dlValues) ->
        color = ''
        value=dlValues[fieldName]
        if value != '-'
          aval = Math.abs value
          if aval >= 50
            color = '#ff0000'
          else if aval >= 35
            color = '#ffff00'
          else if aval >= 20
            color = '#a0ffa0'
          else color = '#d0d0ff'
        return color
        
      dt: (fieldName, dlValues) ->
        color = ''
        value = dlValues[fieldName]
        if value != '-'
          if value >= 50.0
            color='#ff0000'
          else if value >=40.0
            color='#ffff00'
          else if value >=3.0
            color='#a0ffa0'
          else if value >= -10.0
            color='#d0d0ff'
          else if value >= -20.0
            color='#0000ff'
          else color='#ffd0ff'
        color
            
      dv: (fieldName, dlValues) ->
        color=''
        value=dlValues[fieldName]
        if value != '-'
          if value >= 12 || value <= 14
            color='#a0ffa0'
          else if ( value > 14 && value <= 14.5 ) || ( value > 11.8 && value < 12 )
            color = '#f0ffd0'
          else if value > 14.5 || value <= 11.7
            color = '#ff8080'
        color
        
      da: (fieldName, dlValues) ->
        color=''
        value = dlValues[fieldName]
        if value != '-'
          if value >= 1.00
            color = '#ff0000'
          else if value >= 0.2
            color = '#a0ffa0'
          else color = '#d0d0ff'
        color
        
      gpss: (fieldName, dlValues) ->
        color=''
        value = dlValues[fieldName]
        if value != '-'
          switch value
            when 'on', 'ona', 'onc'
              color='#d0d0ff'
            when 'off'
              color='#ffd0aa'
            when 'offg', 'offp'
              color='#d0ffd0'
            when 'offt', 'offc'
              color='#ffd0aa'
            when 'cs'
              color='#ff0000'
            else
              color='#ffd0d0'
        color
        
      gps: (fieldName, dlValues) ->
        color=''
        value=dlValues[fieldName]
        fr=0
        el=0
        d=0
        if value.match /elck/
          el=1
        if value.match /fr/
          fr=1
        if value.match /1d/
          d=1
        if value.match /2d/
          d=2
        if value.match /3d/
          d=3
          
        if fr != 0 || el != 0 || d != 0
          switch d
            when 0
              value = ''
              value += 'l' if el != 0
              value += 'f' if fr != 0
            when 1, 2, 3
              value = "#{d}D"
              value += 'f' if fr != 0
              
        if value != '-'
          switch value
            when 'L', '3D'
              color = '#d0d0ff'
            when '3Df'
              color = '#aaaaff'
            when '2D'
              color = '#d0ffd0'
            when '2Df'
              color = '#aaffaa'
            when '1D'
              color = '#ffffd0'
            when '1Df'
              color = '#ffffaa'
            when 'lf'
              color = '#d0ffd0'
            when 'off'
              color = '#ffd0aa'
            when 'U', 'u', 'nb'
              color = '#ffd0d0'
            when 'uf'
              color = '#ffaaaa'
            else color = '#ff0000'
        color
        
      clq: (fieldName, dlValues) ->
        color=''
        value=dlValues[fieldName]
        if value != '-'
          switch value
            when '5', 'l', 'ex', 'g'
              color = '#d0d0ff'
            when '4', 't', 'k'
              color = '#d0ffd0'
            when '3', 'h'
              color = '#f0ffd0'
            when '2', '1', '0'
              color = '#ff8000'
            when 'cs'
              color = '#ff0000'
            else
              color = '#ff0000'
        color
        
      latlon: (fieldName, dlValues) ->
        color=''
        value=dlValues[fieldName]
        color = '#d0d0ff' if value != '-'
        color
        
      pmp: (fieldName, dlValues) ->
        color = ''
        value = dlValues['opt']
        spi=0
        spo=0
        spi = 1 if value.match /isp1/
        spo = 1 if value.match /isp2/
        
        if spi
          if spo
            color='#ff0000'
          else
            color='#00ff00'
        color
            

        
    
    # Util.formatDl
    # --------------------------------
    # master channel value formatter
    formatDl: (fieldName, dlValues) ->
      # Use a formatter with the same name as the fieldName if available
      return @formatters[fieldName](fieldName, dlValues) if @formatters[fieldName]?
      
      # Otherwise, Lookup table for fieldnames without a dedicated formatter
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
        when 'cld'
          return @formatters.microseconds fieldName, dlValues
        when 'dt'
          return @formatters.degreesC fieldName, dlValues
        when 'dv'
          return @formatters.volts fieldName, dlValues
        when 'da'
          return @formatters.ampsInMilliamps fieldName, dlValues
        when 'lat', 'lon'
          return @formatters.latlon fieldName, dlValues
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
          value=parseInt value
          if !(isNaN value)
            if value >= 1
              txt = "1"
            else if value == 0
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
        
      microseconds: (fieldName, dlValues) ->
        # Convert microseconds to human readable seconds
        txt = ''
        value = dlValues[fieldName]
        if value != '-'
          aval = Math.abs value
          if aval >= Math.pow(10,4)
            txt = _s.sprintf '%.2fs', value/Math.pow(10,6)
          else if aval >= Math.pow(10,3)
            txt = _s.sprintf '%.1fms', value/Math.pow(10,3)
          else txt= _s.sprintf '%dus', +value
        return txt
        
      degreesC: (fieldName, dlValues) ->
        # format degrees given in Centigrade as a whole number
        txt = ''
        value = dlValues[fieldName]
        if value != '-'
          txt = _s.sprintf '%dC', +value
        return txt
        
      volts: (fieldName, dlValues) ->
        txt = ''
        value = dlValues[fieldName]
        if value != '-'
          txt = _s.sprintf '%.1fV', +value
        txt
        
      ampsInMilliamps: (fieldName, dlValues) ->
        txt = ''
        value = dlValues[fieldName]
        if value != '-'
          txt = _s.sprintf '%dmA', value*1000
          
      gps: (fieldName, dlValues) ->
        txt=''
        value=dlValues[fieldName]
        fr=0
        el=0
        d=0
        if value.match /elck/
          el=1
        if value.match /fr/
          fr=1
        if value.match /1d/
          d=1
        if value.match /2d/
          d=2
        if value.match /3d/
          d=3

        if fr != 0 || el != 0 || d != 0
          switch d
            when 0
              value = ''
              value += 'l' if el != 0
              value += 'f' if fr != 0
            when 1, 2, 3
              value = "#{d}D"
              value += 'f' if fr != 0

        if value != '-'
          txt = value
        value
        
      clq: (fieldName, dlValues) ->
        txt = ''
        value = dlValues[fieldName]
        
        if value != '-'
          switch value
            when '5', 'l'
              txt='L'
            when 'ex'
              txt='EX'
            when 'g'
              txt = 'IG'
            when '4', 't'
              txt = 'T'
            when '3', 'h'
              txt = 'H'
            when '2','1','0'
              txt = value
            when 'cs'
              txt = 'IC'
            else
              txt = 'IC'
        txt
        
      latlon: (fieldName, dlValues) ->
        txt = ''
        value = dlValues[fieldName]
        if value != '-'
          txt = _s.sprintf '%.2f', +value
        txt
        
      elev: (fieldName, dlValues) ->
        txt = ''
        value = dlValues[fieldName]
        if value != '-'
          txt = _s.sprintf '%dm', value*1000.0
        txt
        
      pmp: (fieldName, dlValues) ->
        txt = ''
        value = dlValues['opt']
        if value != '-'
          spi = 0
          spo = 0
          
          spi = 1 if value.match /isp1/
          spo = 1 if value.match /isp2/
          
          if spi
            if spo
              txt = 'On'
            else
              txt = 'I'
        txt
          
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
    
    # Returns true if the fieldName in question has an RRDgraph
    # Currently determines this by looking at the fields listed in 
    # app.stations_status_defs  
    hasgraph: (fieldName) ->
      sd=app.station_status_defs
      res=false
      if sd[fieldName]? && sd[fieldName].graph?
        res=sd[fieldName].graph
      res
    
    # Works like the PHP nl2br function. Replaces newlines with HTML <br />  
    nl2br: (input_string) ->
      return input_string.replace /(\r\n|\r|\n)/g, "<br />"

  return Utils
