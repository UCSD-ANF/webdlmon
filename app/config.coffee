# Set the require.js configuration for your application
require.config

  # Initialize the application with the main application file.
  deps: ["main"]

  paths:
    # Javascript folders.
    libs: "../assets/js/libs"
    plugins: "../assets/js/plugins"
    vendor: "../assets/vendor"

    # Libraries.
    jquery: "../assets/js/libs/jquery"
    "jquery.metadata": "../assets/js/libs/jquery.metadata"
    "jquery.tablesorter": "../assets/js/libs/jquery.tablesorter"
    lodash: "../assets/js/libs/lodash"
    backbone: "../assets/js/libs/backbone"
    "underscore.string": "../assets/js/libs/underscore.string"

  shim:
    # jquery.metadata depends on jQuery
    "jquery.metadata": ["jquery"]
    "jquery.tablesorter": ["jquery.metadata"]
    # Backbone library depends on lodash and jQuery.
    backbone:
      deps: ["lodash", "jquery"]
      exports: "Backbone"

    # Backbone.LayoutManager depends on Backbone.
    "plugins/backbone.layoutmanager": ["backbone"]
