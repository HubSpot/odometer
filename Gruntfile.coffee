Path = require('path')
fs = require('fs')

module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")

    coffee:
      compile:
        files:
          'odometer.js': 'odometer.coffee'

    uglify:
      options:
        banner: "/*! <%= pkg.name %> <%= pkg.version %> */\n"

      dist:
        src: 'odometer.js'
        dest: 'odometer.min.js'

    compass:
      dist:
        options:
          sassDir: 'sass'
          cssDir: 'css'

  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-compass'

  grunt.registerTask 'default', ['coffee', 'uglify', 'compass']
