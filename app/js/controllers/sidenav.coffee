angular.module("app").controller "SidenavController", ($scope, $state, $rootScope, Wallet) ->

  $scope.sectionPrimary = [
      { heading: 'index.overview',        route: 'home', icon: 'fa-home' },
      { heading: "index.my_account",      route: 'accounts', icon: "fa-bank" },
      { heading: "index.directory",       route: 'directory.registered', icon: "fa-book" },
      { heading: "index.delegates",       route: 'delegates', icon: "fa-flag" },
      { heading: "index.packets",         route: 'packets', icon: "fa-envelope" },
      { heading: "index.notes",           route: 'notebooks', icon: "fa-flag" },
      { heading: "index.block_explorer",  route: 'blocks', icon: "fa-link" }
  ]

  $scope.sectionSecondary = [
      { heading: "index.preferences",   route: 'preferences', icon: "fa-gears" },
      { heading: "index.console",       route: 'console', icon: "fa-terminal" },
      { heading: "index.help",          route: 'help', icon: "fa-question-circle" }
  ]

  Wallet.get_current_or_first_account().then (acct) ->
    $scope.current_account = acct
    $scope.current_account_name = acct.name

  # Wallet.refresh_accounts().then (accts) ->
  #   debugger
  #   $scope.accounts = accts
  #   console.log accts
  # , (err) -> console.log err
  $scope.$watchCollection ->
      Wallet.accounts
  , ->
      $scope.accounts = Wallet.accounts

  # $scope.isSelected = (section) ->
  #     $state.is section.route

  $scope.back = ->
    $rootScope.history_back()

  $scope.forward = ->
    $rootScope.history_forward()

  $scope.close = ->
    console.log 'to be implemented'

  $scope.switchCurrentAccount = (new_account_name) ->
    acct = Wallet.set_current_account_by_name(new_account_name)
    $scope.current_account = acct
