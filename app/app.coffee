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

    # Fields to show
    showFields: [
      "con"
      "gp24"
      "gp1"
      "nr24"
      "opt"
      "pmp"
      "dlt"
      "rtm"
      "tput"
      "ce"
      "pbr"
      "nl24"
      "np24"
      "ni24"
      "dr"
      "br24"
      "bw24"
      "clt"
      "lcq"
      "cld"
      "m0"
      "m1"
      "m2"
      "m3"
      "m4"
      "m5"
      "dt"
      "dv"
      "da"
      "gpss"
      "gps"
      "clq"
      "lat"
      "lon"
      "elev"
      "acok"
    ]
    
    station_status_defs:
      dlname:
        title: "dlname"
        sizestr: "XXXXXXXXX"
        justify: "left"
        description: """Datalogger name.  (Usually the SEED net_sta.)
green   - Currently connected and acquiring data
cyan    - Waiting for a datalogger POC
orange  - Establishing a connection
red     - Sleeping after a connection setup failure
magenta - Hibernating
yellow  - NULL datalogger ip-address
gray    - Stopped"""
      model:
        title: "model"
        sizestr: "XXXXXX"
        justify: "left"
        description: "Datalogger model."
      comt:
        title: "comt"
        sizestr: "XXXX"
        justify: "center"
        derived: true
        description: """Communications type.
cpoc - Cell phone POC
rint - Regular internet
cble - Cable internet
cbmod - Cable modem
dsl  - DSL
orb2orb - BRTT ORB to ORB
ssr - Spread spectrum radio
vsat - VSAT"""
      prov:
        title: "comp"
        sizestr: "XXX"
        justify: "center"
        derived: true
        description: "Communications provider."
      STATUS_LATENCY:
        title: 'SLT'
        sizestr: '000d00h00m00s'
        sort: "numerical"
        null: -999999999.9
        justify: "right"
        description: "Status latency - Age of last status packet received"
      dr:
        title: "dr"
        sizestr: "XXXX"
        sort: "numerical"
        null: -999999999.9
        justify: "center"
        description: "Input & output data rate in bits per second"
      br24:
        title: "br24"
        sizestr: "XXXX"
        sort: "numerical"
        null: -999999999.9
        justify: "center"
        graph: true
        description: "Total number of bytes read in last 24 hours"
      bw24:
        title: "bw24"
        sizestr: "XXXX"
        sort: "numerical"
        null: -999999999.9
        justify: "center"
        graph: true
        description: "Total number of bytes written in last 24 hours"
      ce:
        title: "cme"
        sizestr: "00000"
        sort: "numerical"
        justify: "center"
        graph: true
        description: "Communication efficiency as a percentage of processed to read + missed packets"
      pb:
        title: "buf"
        sizestr: "00000"
        sort: "numerical"
        justify: "center"
        null: -999999999.9
        graph: true
        description: "Percent of datalogger buffer full"
      pbr:
        title: "bufr"
        sizestr: "00000"
        sort: "numerical"
        justify: "center"
        null: -999999999.9
        description: "Percent of datalogger buffer full"
      clt:
        title: "cltncy"
        sizestr: "-000d00h00m00s"
        sort: "numerical"
        justify: "right"
        null: -999999999.9
        graph: true
        description: "Clock latency - Age of last GPS clock update."
      dlt:
        title: "dltncy"
        sizestr: "-0000d00h00m00s"
        sort: "numerical"
        null: "999999999.9"
        justify: "right"
        graph: true
        description: "Data latency - Age of last data packet sample received."
      rtm:
        title: "runtm"
        sizestr: "-0000d00h00m00s"
        sort: "numerical"
        null: -999999999.9
        justify: "right"
        description: """blue     - Running time since current connection was established.
not blue - Running time since connection has been down."""
      gp24:
        title: "gp24"
        sizestr: "XXXX"
        null: -999999999.9
        justify: "center"
        description: "data gaps in last 24 hours"
      gp1:
        title: "gp1"
        sizestr: "XXXX"
        null: -999999999.9
        justify: "center"
        graph: true
        description: "data gaps in last 1 hour"
      nl24:
        title: "nl24"
        sizestr: "XXXX"
        sort: "numerical"
        null: -999999999.9
        justify: "center"
        graph: true
        description: "comm link cycles in last 24 hours"
      np24:
        title: "np24"
        sizestr: "XXXX"
        sort: "numerical"
        null: -999999999.9
        justify: "center"
        description: "POCs received in last 24 hours"
      ni24:
        title: "ni24"
        sizestr: "XXXX"
        sort: "numerical"
        null: -999999999.9
        justify: "center"
        description: "datalogger ip-address changes in last 24 hours"
      nr24:
        title: "nr24"
        sizestr: "XXXX"
        sort: "numerical"
        null: -999999999.9
        justify: "center"
        graph: true
        description: "datalogger reboots in last 24 hours"
      tput:
        title: "tp"
        sizestr: "000.00"
        sort: "numerical"
        null: -999999999.9
        justify: "center"
        description: "Thruput as a ratio of seconds read to the real-time clock"
      lcq:
        title: "lcq"
        sizestr: "00000"
        sort: "numerical"
        null: -999999999.9
        justify: "center"
        graph: true
        description: "Percent clock quality"
      cld:
        title: "cld"
        sizestr: "1000ms"
        justify: "center"
        sort: "numerical"
        graph: true
        description: "Clock drive from true second mark registration"
      m0:
        title: "m0"
        sizestr: "-128"
        justify: "center"
        sort: "numerical"
        graph: true
        description: "Seismometer mass position for physical channel 0. Ranges from -128 to +127"
      m1:
        title: "m1"
        sizestr: "-128"
        justify: "center"
        sort: "numerical"
        graph: true
        description: "Seismometer mass position for physical channel 1. Ranges from -128 to +127"
      m2:
        title: "m2"
        sizestr: "-128"
        justify: "center"
        sort: "numerical"
        graph: true
        description: "Seismometer mass position for physical channel 2. Ranges from -128 to +127"
      m3:
        title: "m3"
        sizestr: "-128"
        justify: "center"
        sort: "numerical"
        graph: true
        description: "Seismometer mass position for physical channel 3. Ranges from -128 to +127"
      m4:
        title: "m4"
        sizestr: "-128"
        justify: "center"
        sort: "numerical"
        graph: true
        description: "Seismometer mass position for physical channel 4. Ranges from -128 to +127"
      m5:
        title: "m5"
        sizestr: "-128"
        justify: "center"
        sort: "numerical"
        graph: true
        description: "Seismometer mass position for physical channel 5. Ranges from -128 to +127"
      "m0-2":
        title: "m0-2"
        sizestr: "XXXXX"
        justify: "center"
        sort: "real"
        using: [m0, m1, m2]
        description: "Largest sesimometer mass position for physical channels 0-2. Ranges from -128 to +127"
      "m3-5":
        title: "m0-5"
        sizestr: "XXXXX"
        justify: "center"
        sort: "real"
        using: [m3, m4, m5]
        description: "Largest sesimometer mass position for physical channels 3-5. Ranges from -128 to +127"
      dt:
        title: "temp"
        sizestr: "-50C"
        justify: "center"
        sort: "numerical"
        graph: true
        description: "Digitizer temperature"
      dv:
        title: "volt"
        sizestr: "00.0V"
        justify: "center"
        sort: "numerical"
        graph: true
        description: "Digitizer voltage"
      da:
        title: "amp"
        sizestr: "1000mA"
        justify: "center"
        sort: "numerical"
        graph: true
        description: "Digitizer current"
      gpss:
        title: "gpss"
        sizestr: "XXXX"
        justify: "center"
        description: """GPS status
off    - powered off
offg   - powered off due to GPS lock
offp   - powered off due to PLL lock
offt   - powered off due to time limit
offc   - powered off by command
on     - powered on
ona    - powered on automatically
onc    - powered on by command
cs     - cold start"""
      gps:
        title: "gps"
        sizestr: "offp"
        justify: "center"
        description: """GPS position fix quality
3D  - best quality, 3-dimensional fix
2D  - 2-dimension (lat-lon) fix
1D  - poor quality, 1-dimension fix
L   - gps locked - unknown fix
U   - gps not locked - unknown fix
3Df - gps off, last fix was 3D
2Df - gps off, last fix was 2D
1Df - gps off, last fix was 1D
lf  - gps off, clock was ever locked
off - gps off, unknown lock
nb  - no gps board"""
      clq:
        title: "pll"
        sizestr: "XXX"
        justify: "center"
        description: """Clock status.
L  - VCO phase locked.
T  - VCO tracking for phase lock.
H  - VCO holding (determining clock drift)
IC - Bad clock (no GPS reception, on local clock)
EX - Synced with external clock
IG - Synced with internal GPS
K  - Set with keyboard"""
      lat:
        title: "lat"
        sizestr: "0000.000"
        justify: "right"
        sort: "numerical"
        description: "GPS reported latitude"
      lon:
        title: "lon"
        sizestr: "00000.000"
        justify: "right"
        sort: "numerical"
        description: "GPS reported longitude"
      elev:
        title: "elev"
        sizestr: "00000m"
        justify: "right"
        sort: "numerical"
        description: "GPS reported elevation"
      pmp:
        title: "pmp"
        sizestr: "XXX"
        justify: "center"
        description: """Sump pump disposition
I   - installed and not on
On  - installed and on"""
      acok:
        title: "acok"
        sizestr: "X"
        justify: "center"
        description: """Reserve battery:
0 - VIE on reserve battery power or else no VIE,
1 - VIE on normal power,
- - Unknown"""
      opt:
        title: "opt"
        justify: "center"
        description: """Q330 Options bitfield
ins1 - Pump installed
ins2 - Pump is On
ti - Baler44 connected to VIE
api - Wiring Error"""

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
