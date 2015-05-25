angular.module("app").controller "NotebooksController", ($scope, Wallet, $state) ->

    $scope.account_names = []
    Wallet.refresh_accounts().then ->
        accounts = Wallet.accounts
        for item of Wallet.accounts
          $scope.account_names.push
            name: item
            registered: accounts[item].registered

    $scope.gotoBook = (account) ->
        if account.registered
          $state.go( 'notes', { name: account.name } )
