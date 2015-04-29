coffee =
  compile:
    files:
      'lib/musicplayer-api.js' : 'src/musicplayer-api.coffee'

coffeelint =
  app: ['src/*.coffee']
  options:
    no_empty_param_list:
      level: 'error'

uglify =
  options:
    mangle: false
  my_target:
    files:
      'lib/musicplayer-api.min.js' : ['lib/musicplayer-api.js']

module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    coffee: coffee
    coffeelint: coffeelint
    uglify: uglify

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.registerTask 'default', ['coffeelint', 'coffee']
  grunt.registerTask 'all', ['coffeelint', 'coffee', 'uglify']
