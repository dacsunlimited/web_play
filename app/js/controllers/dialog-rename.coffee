angular.module("app").controller "DialogRenameController", ($scope, $uibModalInstance, oldname, Wallet, $location) ->

    $scope.m = {}
    $scope.m.oldname = oldname
    $scope.m.newname = oldname
    $scope.m.translate_data = {value: oldname}

    $scope.cancel = ->
        $uibModalInstance.dismiss "cancel"

    $scope.ok = ->
      Wallet.wallet_rename_account(oldname, $scope.m.newname).then ->
        $uibModalInstance.close("ok")
        $location.path("accounts/"+$scope.m.newname)
