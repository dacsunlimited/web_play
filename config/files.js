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
        "vendor/bower/angular/angular.js",
        "vendor/bower/angular-messages/angular-messages.js",
        "vendor/js/bootstrap.js",
        // angular-material
        "vendor/bower/angular-animate/angular-animate.js",
        "vendor/bower/angular-aria/angular-aria.js",
        "vendor/bower/hammerjs/hammer.js",
        "vendor/bower/angular-material/angular-material.js",

        "vendor/bower/angular-resource/angular-resource.js",
        // "vendor/bower/angular-ui-router/angular-ui-router.js",
        "vendor/js/angular-ui-router.js",
        "vendor/bower/angular-translate/angular-translate.js",
        "vendor/bower/angular-translate-loader-static-files/angular-translate-loader-static-files.js",

        "vendor/bower/angular-pageslide-directive/dist/angular-pageslide-directive.js",
        "vendor/bower/ng-idle/angular-idle.js",
        "vendor/bower/angular-bootstrap/ui-bootstrap.js",
        "vendor/bower/angular-bootstrap/ui-bootstrap-tpls.js",
        "vendor/bower/angular-ui-grid/ui-grid.js",
        "vendor/bower/angular-ui-utils/validate.js",
        "vendor/bower/angular-xeditable/dist/js/xeditable.js",
        "vendor/bower/moment/min/moment-with-locales.js",
        // "vendor/js/ui-bootstrap-tpls.js",
        //  "vendor/js/ui-grid.js",
        // "vendor/js/angular-idle.js",
        // "vendor/js/validate.js",
        // "vendor/js/xeditable.js",
        // "vendor/js/angular-translate.min.js",
        // "vendor/js/angular-translate-loader-static-files.min.js",
        "vendor/js/jsonpath.js",
        "vendor/js/highstock.src.js",


    // version conflicts to solve
    // "angular-pageslide-directive": "~0.1.8",
    // "ng-idle": "~0.3.5"


        // "vendor/js/jquery.js",
        // "vendor/js/jquery.growl.js",
        // // "vendor/js/ark.js",
        // "vendor/js/stacktrace.js",
        // "vendor/js/angular.js",
        // "vendor/js/angular-resource.js",
// "vendor/js/angular-idle.js",
        // "vendor/js/angular-ui-router.js",
        // "vendor/js/ui-bootstrap-tpls.js",
        // "vendor/js/ui-grid.js",
        // "vendor/js/angular-idle.js",
        // "vendor/js/validate.js",
        // "vendor/js/xeditable.js",
        // "vendor/js/angular-translate.min.js",
        // "vendor/js/angular-translate-loader-static-files.min.js",
        // "vendor/js/jsonpath.js",
        // "vendor/js/angular-pageslide-directive.js",
        // "vendor/js/highstock.src.js",
        // "vendor/js/moment-with-locales.js"
        "vendor/js/moment-with-locales.js",
        "vendor/js/bytebuffer.js"
      ],
      app: [
        "app/js/app.js",
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
        "vendor/bower/angular-material/angular-material.css",
        "vendor/bower/angular-ui-grid/ui-grid.css",
        "vendor/bower/angular-xeditable/dist/css/xeditable.css",
        "vendor/css/bootstrap.css",
        "vendor/css/font-awesome.css",
        "vendor/css/ark.css"


        // "vendor/css/jquery.growl.css",
        // "vendor/css/bootstrap.css",
        // "vendor/css/font-awesome.css",
        // "vendor/css/ark.css",
        // "vendor/css/xeditable.css",
        // "vendor/css/ui-grid.css"
      ],
      app: [
        "app/css/*.css",
        "app/css/main.scss"

        // "app/css/bootstrap_overrides.css",
        // "app/css/main.css",
        // "app/css/forms.css",
        // "app/css/layout.css",
        // "app/css/my-ng-grid.css",
        // "app/css/toolbar.css",
        // "app/css/footer.css",
        // "app/css/market.css",
        // "app/css/spinner.css",
        // "app/css/mail.css",
        // "app/css/help.css",
        // "app/css/splashpage.css",
        //
        // "app/main.scss"
      ]
      // vendor: [
      //   "vendor/css/jquery.growl.css",
      //   "vendor/css/bootstrap.css",
      //   "vendor/css/font-awesome.css",
      //   "vendor/css/ark.css",
      //   "vendor/css/xeditable.css",
      //   "vendor/css/ui-grid.css",
      //   "vendor/css/material.css",
      //   "vendor/css/material-wfont.css",
      //   "vendor/css/ripples.css",
      // ],
      // app: [
      //   "app/css/bootstrap_overrides.css",
      //   "app/css/main.css",
      //   "app/css/forms.css",
      //   "app/css/layout.css",
      //   "app/css/my-ng-grid.css",
      //   "app/css/toolbar.css",
      //   "app/css/footer.css",
      //   "app/css/market.css",
      //   "app/css/spinner.css",
      //   "app/css/help.css",
      //   "app/css/splashpage.scss"
      // ]
    }

  };
};


