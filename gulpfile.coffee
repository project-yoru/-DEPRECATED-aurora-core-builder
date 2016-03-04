gulp = require('gulp-param')(require('gulp'), process.argv);
$ = require('gulp-load-plugins')()
runSequence = require('run-sequence')
gutil = require('gutil')
exec = require('child_process').exec

Options = {}

# gulp.task 'init-structure', ->
#   clone/update structure, install npm, bower, gem packages, etc
# 
#   $.git.addSubmodule('https://github.com/project-yoru/aurora-core-structure', 'structure', { args: '--force -b master'})

gulp.task 'init-app-content', ['clear-app-content', 'clone-app-content']

gulp.task 'clear-app-content', (callback) ->
  # TODO update instead of rm & re-clone

  unless Options.appContentRepoPath?
    console.log 'NO appContentRepoPath, skipping cleaning'
    callback()
  else
    gulp
      .src './app_content', { read: false }
      .pipe $.rimraf()

gulp.task 'clone-app-content', (callback) ->
  # TODO handle custom branch
  # TODO log git clone progress

  unless Options.appContentRepoPath?
    console.log 'NO appContentRepoPath, skipping cloning'
    callback()
  else
    exec "git clone https://github.com/#{Options.appContentRepoPath} ./app_content", (err, stdout, stderr) ->
      gutil.log stdout
      gutil.log stderr
      callback err

gulp.task 'merge-app-content-with-structure', (callback) ->
  # clean
  gulp
    .src './app_merged', { read: false }
    .pipe $.rimraf()

  # copy structure to app_merged
  gulp
    .src [ './structure/**' ], { dot: true }
    .pipe gulp.dest './app_merged'

  # merge contents in app_content into app_merged
  gulp
    .src [ './app_content/config', './app_content/resources', './app_content/story' ], { dot: true }
    .pipe gulp.dest './app_merged/app'

gulp.task 'build-app', (callback) ->

  build_command = 'cd ./app_merged && gulp'

  exec "bash -lc \"#{build_command}\"", (err, stdout, stderr) ->
  # exec 'source ~/.rvm/scripts/rvm && cd ./app_merged && gulp', (err, stdout, stderr) ->
    gutil.log stdout
    gutil.log stderr
    callback err

gulp.task 'cleanup', (callback) ->
  files_to_exclude_in_structure = [
    'bower.json'
    'Gemfile'
    'Gemfile.lock'
    'gulpfile.coffee'
    'LICENSE'
    'package.json'
    'README.md'
    'TODO'
    'wct.conf.js'
  ]

  # TODO rm

gulp.task 'build', (appContentRepoPath, appContentRepoBranch = 'master', environment = 'development', callback) ->
  # TODO logging

  # TODO valid params

  # get options
  Options['environment'] = environment
  Options['appContentRepoPath'] = appContentRepoPath
  Options['appContentRepoBranch'] = appContentRepoBranch

  runSequence(
    # 'init-structure'
    'init-app-content'
    'merge-app-content-with-structure'
    'build-app'
    'cleanup'
  )
