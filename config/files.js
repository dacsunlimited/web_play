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
        "node_modules/jquery/dist/jquery.min.js",
        "node_modules/angular/angular.js",
        "node_modules/angular-growl-v2/build/angular-growl.js",
        "vendor/js/stacktrace.js", // "node_modules/stacktrace-js/stacktrace.js",
        // "vendor/js/bootstrap.js", // node_modules/angular-bootstrap/ui-bootstrap.min.js ? it's been included below maybe can be deleted

        // angular-material
        "node_modules/angular-aria/angular-aria.js",
        "node_modules/angular-animate/angular-animate.js",
        "node_modules/angular-material/angular-material.js",
        "node_modules/angular-messages/angular-messages.js",
        // float button
        "node_modules/ng-material-floating-button/src/mfb-directive.js",


        "node_modules/angular-resource/angular-resource.js",
        "node_modules/angular-ui-router/release/angular-ui-router.js", // originally "vendor/js/angular-ui-router.js",
        "node_modules/angular-pageslide-directive/dist/angular-pageslide-directive.js",
        // "node_modules/angular-bootstrap/ui-bootstrap.js",
        // "node_modules/angular-bootstrap/ui-bootstrap-tpls.js",
        "node_modules/angular-ui-bootstrap/dist/ui-bootstrap.js",
        "node_modules/angular-ui-bootstrap/dist/ui-bootstrap-tpls.js",
        "node_modules/moment/min/moment-with-locales.js",
        "node_modules/moment-timezone/builds/moment-timezone-with-data-2010-2020.min.js",

        "node_modules/angular-ui-grid/ui-grid.js",
        "node_modules/ng-idle/angular-idle.js",
        "node_modules/angular-ui-utils/modules/validate/validate.js",
        "node_modules/angular-xeditable/dist/js/xeditable.js",
        "node_modules/angular-translate/dist/angular-translate.js",
        "node_modules/angular-translate-loader-static-files/angular-translate-loader-static-files.js",

        "vendor/js/jsonpath.js",
        "vendor/js/bytebuffer.js",
        "vendor/js/sha256.js",
        "vendor/js/jdenticon.js",
        "node_modules/angular-touch/angular-touch.js", //angular-material doesn't like this, but angular-carousel depends on it
        "node_modules/angular-carousel/dist/angular-carousel.js",

        //js-combinatorics
        "node_modules/js-combinatorics/combinatorics.js",

        //games
        "vendor/js/games/TweenMax.min.js",
        "vendor/js/games/Winwheel.js"
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
        "vendor/css/bootstrap.css",
        "node_modules/angular-ui-bootstrap/dist/ui-bootstrap-csp.css",
        "vendor/css/font-awesome.css",
        "vendor/css/ark.css",
        "node_modules/angular-growl-v2/build/angular-growl.min.css", //original "node_modules/growl/stylesheets/jquery.growl.css",
        "node_modules/angular-ui-grid/ui-grid.min.css",
        "node_modules/angular-xeditable/dist/css/xeditable.min.css",
        "node_modules/angular-carousel/dist/angular-carousel.min.css",
        "node_modules/angular-material/angular-material.min.css",
        "node_modules/ng-material-floating-button/mfb/dist/mfb.css",
        "vendor/css/ionicons.css"
      ],
      app: [
        "app/css/main.scss"
      ]
    }

  };
};


