angular.module("app").controller "PacketNewController", ($scope, $q, BlockchainAPI, Wallet, Info, WalletAPI, Utils, RpcService, $mdDialog, Growl, $translate) ->

  $scope.form = null
  $scope.frm_data =
    amount:
      amount: 100
      symbol: Info.symbol
    from_account_name: Wallet.current_account?.name
    message: ""
    password: ""
    count: 5

  $scope.my_accounts = []

  Wallet.get_current_or_first_account().then (acct)->
    $scope.frm_data.from_account_name = acct.name

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

  getAccountsWithBalance(Info.symbol)

  # check claim statuses
  $scope.$watch ->
    Wallet.current_account
  , (newVal, oldVal, scope)->
    $scope.frm_data.from_account_name = newVal?.name

  $scope.checkForm = ->
    if $scope.form.$valid
      return true
    else
      for err_type, objs of $scope.form.$error
        objs[0].$setDirty()
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
    , (error) ->
      # code = error.response.data.error.code
      # $scope.form.password.$dirty = true
      # $scope.form.password.$valid = false
      #
      # if code == 31005
      #     $scope.form.password.$error.badPassword = true
      # else if code == 20010
      #     $scope.form.password.$error.insufficientFund = true
      # else if code == 10
      #
      #   if error.message.indexOf("All of this red packet has already been claimed!") > -1
      #     $scope.form.password.$error.allClaimed = true
      #   else if error.message.indexOf("This account already claimed this packet!") > -1
      #     $scope.form.password.$error.dupClaim = true
      #   else if error.message.indexOf("to_account_rec.valid") > -1
      #     $scope.form.password.$error.accountNotRegistered = true
      #
      # else
      #     $scope.form.password.error_message = Utils.formatAssertException(error.data.error.message)