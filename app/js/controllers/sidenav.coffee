angular.module("app").controller "SidenavController", ($scope, $location, $state) ->
  $scope.back = ->
    $scope.history_back()

  $scope.forward = ->
    $scope.history_forward()

  $scope.close = ->
    # close sidenav