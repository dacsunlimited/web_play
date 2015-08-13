angular.module("app").controller "PacketController", ($scope, $q, BlockchainAPI, Wallet, WalletAPI, Utils, RpcService, $mdDialog, Growl, $translate, id, packet) ->

  $scope.packet = packet if packet
  $scope.claimers = []

  $scope.form = null
  $scope.frm_data =
    id: packet?.id || null
    to_account_name: Wallet.current_account?.name
    password: packet.password || ""

  my_accounts = []

  Wallet.get_current_or_first_account().then (acct)->
    $scope.frm_data.to_account_name = acct.name

    # my registered accounts
    for k, acct of Wallet.accounts
      my_accounts.push acct.id if acct.id > 0


  # refresh packet data
  BlockchainAPI.get_red_packet(id).then (data) ->
    if data
      $scope.packet = data

      $scope.packet.claimed_count ||= 0
      $scope.packet.slots_count   ||= $scope.packet.claim_statuses.length
      # $scope.packet.amount  ||= $scope.packet.claim_statuses.reduce (x, y) -> x?.amount?.amount || 0 + y?.amount?.amount || 0

      req =
        # get amount asset
        amount_asset: BlockchainAPI.get_asset($scope.packet.amount.asset_id)
        # sender
        sender: BlockchainAPI.get_account(data.from_account_id)

      $q.all(req).then (data) ->
        $scope.packet.amount.symbol     = data.amount_asset.symbol
        $scope.packet.amount.precision  = data.amount_asset.precision
        $scope.packet.from_account      = data.sender

        # claimers
        account_mapping = {}
        claimer_ids = ($scope.packet.claim_statuses.filter (s) -> s.account_id != -1).map (s) -> [s.account_id]

        if claimer_ids.length > 0
          RpcService.request('batch', ['blockchain_get_account', claimer_ids]).then (data) ->
            if data.result.length > 0
              account_mapping[account.id] = account for account in data.result

            for status in $scope.packet.claim_statuses
              if status.account_id != -1
                status.amount.symbol = $scope.packet.amount.symbol
                status.amount.precision = $scope.packet.amount.precision
                status.claimer = account_mapping[status.account_id]
                status.claimer.is_mine = my_accounts.indexOf(status.account_id) > -1
                $scope.claimers.push status

            # update claimed_count
            $scope.packet.claimed_count = $scope.claimers.length

            account_mapping = null

    else
      $translate('packet.tip.not_found').then (val) -> Growl.notice "", val

  , (err) ->
    Growl.notice "", "Error occured"
    # if (err.response.data.error.code == 20010)
    #     $translate('market.tip.insufficient_balances').then (val) ->
    #         Growl.notice "", val


    # check claim statuses
    $scope.watch ->
      Wallet.current_account
    , ->
      # $scope.packet
      form.to_account_name = Wallet.current_account.name

    # highlight my claimed (my means any account in my wallet)
    $scope.watchCollection ->
      Wallet.accounts
    , ->
      my_accounts = []
      my_accounts.push acct.id if acct.id > 0 for k, acct of Wallet.accounts

      for status in $scope.claimers
        status.claimer.is_mine = my_accounts.indexOf(status.account_id) > -1


  $scope.hide = ->
    $mdDialog.hide()
  $scope.cancel = ->
    $mdDialog.cancel()
  $scope.claim = () ->
    WalletAPI.claim_red_packet($scope.frm_data.id, $scope.frm_data.to_account_name, $scope.frm_data.password).then (response) =>
      $translate('packet.tip.successful_claimed').then (val) -> Growl.notice "", val
      $mdDialog.hide(true)
    , (error) ->
      code = error.response.data.error.code
      $scope.form.password.$dirty = true
      $scope.form.password.$valid = false

      if code == 31005
          $scope.form.password.$error.badPassword = true
      if code == 20010
          $scope.form.password.$error.insufficientFund = true
      else if code == 10

        if error.message.indexOf("All of this red packet has already been claimed!") > -1
          $scope.form.password.$error.allClaimed = true
        else if error.message.indexOf("This account already claimed this packet!") > -1
          $scope.form.password.$error.dupClaim = true

      else
          $scope.form.password.error_message = Utils.formatAssertException(error.data.error.message)
    # $mdDialog.hide()
