angular.module("app").controller "DialogConfirmationController", ($scope, $uibModalInstance, title, message, action) ->

    $scope.title=title
    $scope.message = message

    $scope.cancel = ->
        $uibModalInstance.dismiss "cancel"

    $scope.ok = ->
        action()
        $uibModalInstance.close("ok")
