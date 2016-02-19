gulp = require('gulp-param')(require('gulp'), process.argv);
$ = require('gulp-load-plugins')()
runSequence = require('run-sequence')
gutil = require('gutil')
del = require('del')
exec = require('child_process').exec

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
  # TODO log git clone progress

  exec "git clone https://github.com/#{Options.appContentRepoPath} ./app_content", (err, stdout, stderr) ->
    gutil.log stdout
    gutil.log stderr
    callback err

gulp.task 'init-dist', (callback) ->
  runSequence 'clear-dist', 'copy-structure-as-dist', callback

gulp.task 'clear-dist', (callback) ->
  del ['./app_dist'], { force: true }, callback

gulp.task 'copy-structure-as-dist', (callback) ->
  gulp
    .src './structure/**'
    .pipe gulp.dest './app_dist'

gulp.task 'merge-content', (callback) ->
  # merge resources in app_content into app_dist

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
