angular.module("app").controller "SidenavController", ($scope, $state, $rootScope) ->

  $scope.sectionPrimary = [
      { heading: 'index.overview',        route: 'home', icon: 'fa-home' },
      { heading: "index.my_account",      route: 'accounts', icon: "fa-bank" },
      { heading: "index.directory",       route: 'directory.registered', icon: "fa-book" },
      { heading: "index.delegates",       route: 'delegates', icon: "fa-flag" },
      { heading: "index.notes",           route: 'notebooks', icon: "fa-flag" },
      { heading: "index.block_explorer",  route: 'blocks', icon: "fa-link" }
  ]

  $scope.sectionSecondary = [
      { heading: "index.preferences",   route: 'preferences', icon: "fa-gears" },
      { heading: "index.console",       route: 'console', icon: "fa-terminal" },
      { heading: "index.help",          route: 'help', icon: "fa-question-circle" }
  ]

  # $scope.isSelected = (section) ->
  #     $state.is section.route

  $scope.back = ->
    $rootScope.history_back()

  $scope.forward = ->
    $rootScope.history_forward()

  $scope.close = ->
    console.log 'to be implemented'