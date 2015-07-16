window.getStackTrace = ->
    trace = printStackTrace()
    for value, index in trace
       if value.indexOf("getStackTrace@") >= 0
           trace.splice(0, index) if index >= 0
           break
    trace.join("\n ○ ")

window.open_external_url = (url) ->
    if magic_unicorn?
        magic_unicorn.open_in_external_browser(url)
    else
        window.open(url)


app = angular.module("app",
    ["ngResource", "ui.router", 'ngIdle', "app.services", "app.directives", "ui.bootstrap",
     "ui.validate", "xeditable", "pascalprecht.translate", "pageslide-directive", "ui.grid",
     "ngMaterial", "utils.autofocus", "ngMessages", "ui.grid.autoResize", "ngAnimate",
    "ng-mfb", "angular-carousel"])

app.run ($rootScope, $location, $idle, $state, $interval, $window, $templateCache, $translate, editableOptions, editableThemes) ->

    $templateCache.put 'ui-grid/uiGridViewport',
        '''<div class="ui-grid-viewport">
             <div class="ui-grid-canvas">
               <div ng-repeat="(rowRenderIndex, row) in rowContainer.renderedRows track by row.uid" class="ui-grid-row" ng-class="row.entity.type" ng-style="containerCtrl.rowStyle(rowRenderIndex)">
                 <div ui-grid-row="row" row-render-index="rowRenderIndex"></div>
               </div>
              </div>
           </div>'''

    if magic_unicorn? and magic_unicorn.get_os_name
        $rootScope.qt_os_name = magic_unicorn.get_os_name()
    else
        $rootScope.qt_os_name = "dev"

    $rootScope.context_help = {locale: "en", show: false, file: "", open: false}
    app_history = []

    $rootScope.magic_unicorn = if magic_unicorn? then magic_unicorn else false
    $rootScope.magic_unicorn.log_message(navigator.userAgent) if $rootScope.magic_unicorn

    window.navigate_to = (path) ->
        if path[0] == "/"
            window.location.href = "/#" + path
        else
            $state.go(path)

    editableOptions.theme = 'default'
    editableThemes['default'].submitTpl = '<button type="submit" class="btn btn-sm btn-primary"><i class="fa fa-check fa-lg"></i></button>'
    editableThemes['default'].cancelTpl = '<button type="button" ng-click="$form.$cancel()" class="btn btn-sm btn-warning"><i class="fa fa-times fa-lg"></i></button>'

    history_back_in_process = false
    $rootScope.$on "$stateChangeSuccess", (event, toState, toParams, fromState, fromParams) ->
        app_history.push {state: fromState.name, params: fromParams} if fromState.name and !history_back_in_process
        from_page = fromState.name.split(".")[0]
        to_page = toState.name.split(".")[0]
        $window.scrollTo(0,0) unless from_page == to_page

    $rootScope.history_back = ->
        return false if app_history.length == 0
        loop
            prev_page = app_history.pop()
            break unless prev_page
            break unless prev_page.state == "createwallet" or prev_page.state == "unlockwallet"
        # return false if window.history.length < history_counter
        # if prev_page
        #     navigate_to(prev_page.state)
        #     return true
        # $window.history.go(0 - history_counter)
        # return true
        if prev_page
            history_back_in_process = true
            $state.transitionTo(prev_page.state, prev_page.params).then (res) ->
                history_back_in_process = false
        return !!prev_page

    $rootScope.history_forward = ->
        $window.history.forward()

    $rootScope.loading_indicator = {show: false,  progress: null}
    $rootScope.showLoadingIndicator = (promise, progress = null) ->
        li = $rootScope.loading_indicator
        li.show = true
        li.progress = if progress then progress.replace("{{value}}", '0') else ""
        promise.then ->
            li.show = false
        , ->
            li.show = false
        ,  (value) ->
            li.progress = progress.replace("{{value}}", value) if progress

    $rootScope.showContextHelp = (name) ->
        if name
            $rootScope.context_help.show = true
            $rootScope.context_help.file = "context_help/en/#{name}.html"
        else
            $rootScope.context_help.show = false
            $rootScope.context_help.file = ""

    $rootScope.current_account = null

    $idle.watch()

app.config ($mdThemingProvider, $idleProvider, $translateProvider, $tooltipProvider, $compileProvider) ->
    $mdThemingProvider.theme('default').primaryPalette('indigo')

    $compileProvider.debugInfoEnabled false
    # set this to false in production to gain performance boost
    # use angular.reloadWithDebugInfo() to reload the page and obtain debug capability

    $tooltipProvider.options { appendToBody: true }

    $translateProvider.useStaticFilesLoader
        prefix: 'locale-',
        suffix: '.json'

    [lang,zone] = switch(window.navigator.language.toLowerCase())
      when "zh-cn" then ["zh-CN","Asia/Shanghai"]
      when "de", "de-de" then ["de","Europe/Berlin"]
      when "ru", "ru-ru" then ["ru","Europe/Moscow"]
      when "it", "it-it" then ["it","Europe/Rome"]
      when "ko", "ko-kr" then ["ko","Asia/Seoul"]
      when "es", "es-ar", "es-bo", "es-cl", "es-co", "es-cr", "es-do", "es-ec", "es-sv", "es-gt", "es-hn", "es-mx", "es-ni", "es-pa", "es-py", "es-pe", "es-pr", "es-es", "es-uy", "es-ve" then ["es","UTC"]
      else ["en","UTC"]

    moment.locale(lang)
    moment.tz.setDefault(zone)

    $translateProvider.preferredLanguage(lang).fallbackLanguage('en')

    $idleProvider.idleDuration(1776)
    $idleProvider.warningDuration(60)

# define app.services module
angular.module("app.services", [])
