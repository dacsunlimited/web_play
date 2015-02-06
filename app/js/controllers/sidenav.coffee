angular.module("app").controller "SidenavController", ($scope, $rootScope) ->
  $scope.back = ->
    $rootScope.history_back()

  $scope.forward = ->
    $rootScope.history_forward()

  $scope.close = ->
    console.log 'to be implemented'