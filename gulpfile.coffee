path       = require 'path'
gulp       = require 'gulp'
CSSmin     = require 'gulp-minify-css'
uglify     = require 'gulp-uglify'
coffee     = require 'gulp-coffee'
ecstatic   = require 'ecstatic'
livereload = require 'gulp-livereload'
prefix     = require 'gulp-autoprefixer'
lr         = require 'tiny-lr'
reloadServer = lr()
$ = require('gulp-load-plugins')()
config = require './package.json'

production = process.env.NODE_ENV is 'production'

paths =
  scripts:
    source: './src/app/**/*.coffee'
    watch: './src/app/**/*.coffee'
    destination: './public/js/'
  templates:
    source: './src/templates/**/*.html'
    watch: './src/templates/**/*.html'
  styles:
    source: './src/stylus/style.styl'
    watch: './src/stylus/**/*.styl'
    destination: './public/css/'
  assets:
    source: './src/assets/**/*.*'
    watch: './src/assets/**/*.*'
    destination: './public/'

handleError = (err) ->
  $.util.log err
  $.util.beep()
  this.emit('end')

gulp.task 'scripts', ->
  scripts = gulp.src(paths.scripts.source)
    .pipe($.ngClassify(
      appName: 'ham'
    ))
    .pipe($.coffee(bare: false)).on('error', handleError)
    # make sure ham app is first module initialized
    .pipe($.order(['main.js']))
    .pipe($.filesize())
    .pipe($.concat("app.js"))
  scripts = scripts.pipe($.uglify()) if production
  scripts.pipe(gulp.dest(paths.scripts.destination))
    .pipe($.filesize())
    .pipe livereload reloadServer

gulp.task 'js_libs', ->
  bower_root = './bower_components/'
  # move to package.json?
  lib_list = [
    'angular/angular.js'
    'angular-animate/angular-animate.js'
    'angular-leaflet-directive/dist/angular-leaflet-directive.js'
    'marked/lib/marked.js'
    'angular-marked/angular-marked.js'
    'gsap/src/uncompressed/TweenMax.js'
    'ng-Fx/dist/ng-Fx.js'
    'angularjs-geolocation/src/geolocation.js'
    'angular-ui-router/release/angular-ui-router.js'
  ]
  src_list = lib_list.map (lib) ->
    return bower_root+lib
  lib_names = lib_list.map (lib) ->
    return path.basename(lib)
  libs = gulp
    .src(src_list)
    .pipe($.order(lib_names))
  libs = libs.pipe($.uglify()) if production
  libs
    .pipe($.concat("libs.js"))
    .pipe($.filesize())
    .on 'error', handleError
    .pipe gulp.dest paths.scripts.destination

gulp.task 'templates', ->
  gulp
    .src paths.templates.source
    .pipe($.angularTemplatecache(
      module: 'ham'
    ))
    .on 'error', handleError
    .pipe gulp.dest paths.scripts.destination
    .pipe($.filesize())
    .pipe livereload(reloadServer)

gulp.task 'styles', ->
  styles = gulp
    .src paths.styles.source
    .pipe($.stylus({
      set: ['include css']
      use: ['nib']
    }))
    .on 'error', handleError
    .pipe prefix 'last 2 versions', 'Chrome 34', 'Firefox 28', 'iOS 7'

  styles = styles.pipe(CSSmin()) if production

  styles.pipe gulp.dest paths.styles.destination
    .pipe livereload reloadServer

gulp.task 'assets', ->
  gulp
    .src paths.assets.source
    .pipe gulp.dest paths.assets.destination
    .pipe($.filesize())
    .pipe livereload(reloadServer)

gulp.task 'server', ->
  require('http')
    .createServer ecstatic(root: __dirname + '/public')
    .listen 9001

gulp.task "watch", ->
  reloadServer.listen 35729

  gulp.watch paths.templates.watch, ['templates']
  gulp.watch paths.scripts.watch, ['scripts']
  gulp.watch paths.styles.watch, ['styles']
  gulp.watch paths.assets.watch, ['assets']

# TODO: test
gulp.task 'deploy', ->
  gulp.src("./public/**/*")
    .pipe($.ghPages())

gulp.task "build", ['scripts', 'templates', 'styles', 'assets', 'js_libs']
gulp.task "default", ["build", "watch", "server"]
