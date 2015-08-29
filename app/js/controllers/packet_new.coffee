angular.module("app").controller "PacketNewController", ($scope, $q, BlockchainAPI, Wallet, Info, WalletAPI, Utils, RpcService, $mdDialog, Growl, $translate) ->

  $scope.form = null
  $scope.frm_data =
    amount:
      amount: 100
      symbol: Info.symbol
    from_account_name: if Wallet.current_account?.registered then Wallet.current_account?.name else null
    message: ""
    password: ""
    count: 5

  $scope.my_accounts = []

  Wallet.get_current_or_first_account().then (acct)->
    $scope.frm_data.from_account_name = acct.name if acct.registered

  # get accounts with balance of given asset
  # and filter with registered account only
  getAccountsWithBalance = (asset) ->
    $scope.my_accounts = []
    Wallet.refresh_accounts().then (result) ->
      for name, balance of Wallet.balances
        if balance[asset]? && Wallet.accounts[name].id > 0
          acct = Wallet.accounts[name]
          acct.balance = balance[asset]
          $scope.my_accounts.push acct

      # if current account is not regisered
      if !$scope.frm_data.from_account_name and $scope.my_accounts.length > 0
        $scope.frm_data.from_account_name = $scope.my_accounts[0].name

  getAccountsWithBalance(Info.symbol)

  $scope.$watch ->
    Wallet.current_account
  , (newVal, oldVal, scope)->
    $scope.frm_data.from_account_name = newVal?.name if newVal?.registered

  $scope.checkForm = ->
    if $scope.form.$valid
      return true
    else
      for err_type, objs of $scope.form.$error
        objs[0]?.$setDirty()
        return false

  $scope.hide = ->
    $mdDialog.hide()
  $scope.cancel = ->
    $mdDialog.cancel()
  $scope.create = () ->
    return false unless $scope.checkForm()

    frm = $scope.frm_data
    WalletAPI.create_red_packet(frm.amount.amount, frm.amount.symbol, frm.from_account_name, frm.message, frm.password, frm.count).then (response) =>
      $translate('packet.tip.successful_created').then (val) -> Growl.notice "", val
      $mdDialog.hide(true)
    , (err) ->
      error = err.data?.error || err.response?.data?.error
      code  = error.code
      error_message = error.locale_message || error.message

      if code == 20010
        $scope.form.amount.$dirty = true
        $scope.form.amount.$error.remoteError = error_message
      else if code == 10 and error.message.indexOf("The paid amount must larger than the sum") > -1
        $scope.form.amount.$error.remoteError = Utils.formatAssertException(error_message)
      else
        $scope.form.$error.remoteError = Utils.formatAssertException(error_message)
