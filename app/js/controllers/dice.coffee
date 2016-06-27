angular.module("app").controller "DiceController", ($scope, $mdDialog, $stateParams, BlockchainAPI, Blockchain, Utils, Wallet, WalletAPI, $rootScope, RpcService, Info) ->
  $scope.dice_num = Math.floor(Math.random() * 100);
  $scope.guess_num = Math.floor(Math.random() * 100);
  $scope.bet_amount = Math.floor(Math.random() * 100);
