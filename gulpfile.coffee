gulp = require('gulp')

coffee     = require('gulp-coffee')
jison      = require('gulp-jison')
browserify = require('browserify')
source     = require('vinyl-source-stream')
path       = require('path')


paths = {
  scripts: ['src/ml.coffee', 'src/run.coffee'],
  grammer: ['src/grammer.jison']
}

gulp.task('grammer', () =>
  gulp
    .src(paths.grammer)
    .pipe(jison())
    .pipe(gulp.dest('build'))
)

gulp.task('scripts', () =>
  gulp
    .src(paths.scripts)
    .pipe(coffee())
    .pipe(gulp.dest('build'))
)

gulp.task('browserify', ['grammer', 'scripts'], () =>
  file = './build/ml.js'
  browserify(file)
    .require(file, {expose:'ml'})
    .bundle()
    .pipe(source(path.basename('bundle-browserify.js')))
    .pipe(gulp.dest('./build'));
)

gulp.task('watch', () =>
  gulp.watch(['src/*.coffee', 'src/*.jison'], ['default'])
)

gulp.task('default', ['browserify'])


