angular.module("app").controller "NotebooksController", ($scope, Wallet, $state) ->

    $scope.account_names = []
    Wallet.refresh_accounts().then ->
        $scope.account_names.push(item) for item of Wallet.accounts

    $scope.goto_book = (account_name) ->
        $state.go( 'notes', { name: account_name } )

