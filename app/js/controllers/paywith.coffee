angular.module("app").controller "PayWithController", ($scope, $uibModalInstance, Wallet, refresh) ->

  $scope.cancel = ->
    $uibModalInstance.dismiss "cancel"
###
  $scope.ok = ->
  	Wallet.wallet_add_contact_account($scope.name, $scope.address).then (response) ->
  		$uibModalInstance.close("ok")
  		refresh()
  		###