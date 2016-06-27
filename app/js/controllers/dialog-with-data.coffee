angular.module("app").controller "DialogWithDataController", ($scope, $uibModalInstance, data, action) ->

    $scope.data = data

    $scope.cancel = ->
        $uibModalInstance.dismiss "cancel"

    $scope.ok = ->
        action()
        $uibModalInstance.close("ok")
