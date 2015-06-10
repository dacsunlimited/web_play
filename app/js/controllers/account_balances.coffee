angular.module("app").controller "AccountBalancesController", ($scope, $location, $stateParams, $state, Wallet, Utils, Observer) ->
    $scope.accounts = Wallet.accounts
    $scope.balances = Wallet.balances
    $scope.utils = Utils
    $scope.formatAsset = Utils.formatAsset

    $scope.go_to_account = (name) ->
        $state.go("account.transactions", {name: name})

#    Wallet.refresh_accounts(true).then ->
#        $scope.accounts = Wallet.accounts
#        $scope.balances = Wallet.balances
#
    accounts_balance_observer =
        name: "accounts_balance_observer"
        frequency: "each_block"
        update: (data, deferred) ->
            Wallet.refresh_accounts(true).then (result) ->
                $scope.accounts = Wallet.accounts
                $scope.balances = Wallet.balances
                refresh_balance_sum()
            deferred.resolve(true)
    Observer.registerObserver(accounts_balance_observer)

    $scope.$on "$destroy", ->
        Observer.unregisterObserver(accounts_balance_observer)

    refresh_balance_sum = ->
      sum = {}
      for acct, balance of $scope.balances
        for symbol, asset of balance
          if sum[asset]
            sum[symbol].amount += asset.amount
          else
            sum[symbol] = asset

      $scope.balance_sum = sum


    refresh_balance_sum()