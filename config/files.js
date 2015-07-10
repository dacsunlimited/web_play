/* Exports a function which returns an object that overrides the default &
 *   plugin file patterns (used widely through the app configuration)
 *
 * To see the default definitions for Lineman's file paths and globs, see:
 *
 *   - https://github.com/linemanjs/lineman/blob/master/config/files.coffee
 */
module.exports = function(lineman) {
  //Override file patterns here
  return {
    js: {
      vendor: [
        "vendor/bower/jquery/dist/jquery.js",
        "vendor/bower/growl/javascripts/jquery.growl.js",
        "vendor/bower/stacktrace/dist/stacktrace.js",
        "vendor/js/bootstrap.js",

        "vendor/bower/angular/angular.js",
        // angular-material
        "vendor/bower/angular-aria/angular-aria.js",
        "vendor/bower/angular-animate/angular-animate.js",
        "vendor/bower/angular-material/angular-material.js",
        "vendor/bower/angular-messages/angular-messages.js",
        // float button
        "vendor/bower/ng-mfb/src/mfb-directive.js",


        // "vendor/bower/hammerjs/hammer.js",
        "vendor/bower/angular-resource/angular-resource.js",
        "vendor/js/angular-ui-router.js",
        "vendor/bower/angular-pageslide-directive/dist/angular-pageslide-directive.js",
        "vendor/bower/angular-bootstrap/ui-bootstrap.js",
        "vendor/bower/angular-bootstrap/ui-bootstrap-tpls.js",
        "vendor/bower/moment/min/moment-with-locales.js",

        "vendor/bower/angular-ui-grid/ui-grid.js",
        "vendor/bower/ng-idle/angular-idle.js",
        "vendor/bower/angular-ui-utils/validate.js",
        "vendor/bower/angular-xeditable/dist/js/xeditable.js",
        "vendor/bower/angular-translate/angular-translate.js",
        "vendor/bower/angular-translate-loader-static-files/angular-translate-loader-static-files.js",

        "vendor/js/jsonpath.js",
        // "vendor/js/highstock.js",
        // "vendor/js/technical-indicators.src.js",
        // "vendor/js/angu-fixed-header-table.js",
        "vendor/js/bytebuffer.js",
        "vendor/js/sha256.js",
        "vendor/js/jdenticon.js",
        "vendor/bower/angular-touch/angular-touch.min.js",
        "vendor/bower/angular-carousel/dist/angular-carousel.min.js"
      ],
      app: [
        // "app/js/app.js",
        "app/js/**/*.js"
      ]
    },

//    less: {
//      compile: {
//        options: {
//          paths: ["vendor/css/normalize.css", "vendor/css/**/*.css", "app/css/**/*.less"]
//        }
//      }
//    },

    css: {
      vendor: [
        "vendor/bower/growl/stylesheets/jquery.growl.css",
        "vendor/bower/angular-ui-grid/ui-grid.css",
        "vendor/bower/angular-xeditable/dist/css/xeditable.css",
        "vendor/bower/angular-carousel/dist/angular-carousel.css",
        "vendor/css/bootstrap.css",
        "vendor/css/font-awesome.css",
        "vendor/css/ark.css",
        // "vendor/bower/bootstrap-material-design/dist/css/material.min.css",
        "vendor/bower/angular-material/angular-material.css",
        "vendor/bower/ng-mfb/mfb/dist/mfb.css",
        "vendor/css/ionicons.css"
      ],
      app: [
        "app/css/main.scss"
      ]
    }

  };
};


