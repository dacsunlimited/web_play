angular.module("app").controller "PacketController", ($scope, $q, Blockchain, Wallet, WalletAPI, Utils, RpcService, $mdDialog, Growl, $translate, id, password) ->

  $scope.form = null
  $scope.frm_data =
    id: id || null
    to_account_name: Wallet.current_account?.name
    password: password || ""

  my_accounts = []

  Wallet.get_current_or_first_account().then (acct)->
    $scope.frm_data.to_account_name = acct?.name

    # my registered accounts
    for k, acct of Wallet.accounts
      my_accounts.push acct.id if acct.id > 0


  # refresh packet data
  Blockchain.get_red_packets(id).then (data) ->
    if data
      # mark my claims
      for status in data.claim_statuses
        if status.account_id != -1
          status.claimer.is_mine = my_accounts.indexOf(status.account_id) > -1

      $scope.packet = data
    else
      $translate('packet.tip.not_found').then (val) -> Growl.notice "", val

  , (err) ->
    Growl.notice "", "Error occured"

  # check claim statuses
  $scope.$watch ->
    Wallet.current_account
  , ->
    $scope.frm_data.to_account_name = Wallet.current_account?.name


  $scope.hide = ->
    $mdDialog.hide()
  $scope.cancel = ->
    $mdDialog.cancel()
  $scope.claim = () ->
    WalletAPI.claim_red_packet($scope.frm_data.id, $scope.frm_data.to_account_name, $scope.frm_data.password).then (response) =>
      $translate('packet.tip.successful_claimed').then (val) -> Growl.notice "", val
      $mdDialog.hide(true)
    , (err) ->

      $scope.form.password.$dirty = true
      $scope.form.password.$valid = false
      $scope.form.password.$error = {}

      error   = err.data?.error || err.response?.data?.error
      code    = error.code

      if code
        if code == 10 or code == 31005

          if code == 31005
            $scope.form.password.$error.badPassword = true
          else if error.message.indexOf("All of this red packet has already been claimed!") > -1
            $scope.form.password.$error.allClaimed = true
          else if error.message.indexOf("This account already claimed this packet!") > -1
            $scope.form.password.$error.dupClaim = true
          else if error.message.indexOf("to_account_rec.valid") > -1
            $scope.form.password.$error.accountNotRegistered = true

        else

          $scope.form.password.$error.errorMessage = error.locale_message

      else
        $scope.form.password.$error.errorMessage = Utils.formatAssertException(error.message)