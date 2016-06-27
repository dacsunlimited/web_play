angular.module("app").controller "DialogOKController", ($scope, $uibModalInstance, title, message, bsStyle) ->

    $scope.title=title
    $scope.message = message
    $scope.bsStyle = bsStyle

    $scope.ok = ->
        $uibModalInstance.close("ok")
