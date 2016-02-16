gulp = require('gulp-param')(require('gulp'), process.argv);
$ = require('gulp-load-plugins')()
runSequence = require('run-sequence')
gutil = require('gutil')
del = require('del')

Options = {}

# gulp.task 'clone-structure', ->
#   $.git.addSubmodule('https://github.com/project-yoru/aurora-core-structure', 'structure', { args: '--force -b master'})

gulp.task 'init-app-content', (callback) ->
  runSequence 'clear-app-content', 'clone-app-content', callback

gulp.task 'clear-app-content', (callback) ->
  # TODO update instead of rm & re-clone

  del ['./app_content'], { force: true }, callback

gulp.task 'clone-app-content', (callback) ->
  # TODO handle custom branch
  # TODO log progress

  $.git
    .clone "https://github.com/#{Options.appContentRepoPath}", {args: './app_content'}
    .on 'error', gutil.log

gulp.task 'init-dist', (callback) ->
  gulp
    .src './structure/**'
    .pipe gulp.dest './app_dist'

gulp.task 'merge-content', (callback) ->
  # TODO

gulp.task 'build', (appContentRepoPath, appContentRepoBranch = 'master', environment = 'development', callback) ->
  # TODO logging
  # console.log appContentRepoBranch

  # TODO valid params

  # get options
  Options['environment'] = environment
  Options['appContentRepoPath'] = appContentRepoPath
  Options['appContentRepoBranch'] = appContentRepoBranch

  runSequence(
    'init-app-content',
    'init-dist',
    'merge-content'
  )
