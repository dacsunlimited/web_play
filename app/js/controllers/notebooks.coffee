angular.module("app").controller "NotebooksController", ($scope, Wallet, BlockchainAPI, Info, Utils, $state) ->
    $scope.account_names = []
    $scope.pool = {}
    $scope.formatAsset = Utils.formatAsset

    $scope.account_transactions = Wallet.transactions['OP:NOTE']
    $scope.pending_only = false
    $scope.p = {currentPage : 0, pageSize : 20, numberOfPages : 0}
    $scope.q = {}

    Wallet.refresh_accounts().then ->
        accounts = Wallet.accounts
        for item of Wallet.accounts
          $scope.account_names.push
            name: item
            registered: accounts[item].registered

    BlockchainAPI.get_operation_reward('note_op_type').then (results) ->
      $scope.pool = amount: results.fees[0][1], precision: 100000, symbol: Info.info.symbol

    $scope.gotoBook = (account) ->
        if account.registered
          $state.go( 'notes', { name: account.name } )

    if !Wallet.transactions or Wallet.transactions['*']?.length == 0
        Wallet.refresh_transactions().then ->
            $scope.account_transactions = Wallet.transactions['OP:NOTE']
