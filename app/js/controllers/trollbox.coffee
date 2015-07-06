angular.module("app").controller "TrollboxController", ($scope, $modal, $log, RpcService, Wallet, WalletAPI, BlockchainAPI, Blockchain, Growl, Info, Utils) ->
  chatAdPositionAcct  = Info.CHAT_ADD_POSITION_ACCT
  chatAdPricingID     = "plain1m"
  chatListLimit       = 50

  adSpec = null
  $scope.accounts = []
  $scope.from =
    account: null
    isopen: false

  $scope.symbol     = Info.symbol
  $scope.precision  = Info.PRECISION

  $scope.chatBid =
    bidid: "#{chatAdPositionAcct}/#{chatAdPricingID}"
    asset:
      symbol: null
      price: 0
    creative:
      version: 0.1
      type: 'text'
      creative:
        text: null
    starts_at: null

  $scope.messages = []
  form = null


  init = ->
    Wallet.refresh_balances().then (balances) ->
      for account_name, value of balances
        if balance = value[$scope.symbol]
          $scope.accounts.push {account_name: account_name, balance: balance}
      $scope.from.account = $scope.accounts[0] if $scope.accounts.length > 0

      # get account_ids
      names = $scope.accounts.map (acct) -> [acct.account_name]
      RpcService.request("batch_authenticated", ["wallet_get_account",names]).then (response)->
        for i in [0...$scope.accounts.length]
          $scope.accounts[i].account_id = response.result[i].id

        fetchChatMessages(chatListLimit)


    # get ad position spec
    BlockchainAPI.get_account(chatAdPositionAcct).then (response) ->
      ad_spec = try
        angular.fromJson(response.public_data)
      catch err
        null

      if ad_spec and ad_spec.ad and ad_spec.ad.pricing?.length > 0
        adSpec = ad_spec

        plain1m = ad_spec.ad.pricing.filter (p) -> p.id == chatAdPricingID
        if pricing = plain1m[0]
          $scope.chatBid.asset.symbol = pricing.asset
          $scope.chatBid.asset.price = pricing.price


  is_mine = (id, myids) ->
    id != 0 and myids.indexOf(id) > -1

  fetchChatMessages = (limit) ->
    # get latest chat messages (limit n messages)
    BlockchainAPI.get_account_ads(chatAdPositionAcct, limit).then (response) ->
      if response.length > 0
        my_account_ids = $scope.accounts.map (acct) -> acct.account_id
        console.log my_account_ids
        # min amount is 200000
        for message in (response.filter (r) -> r.amount.amount >= 200000 and checkMessageFee(r))
          bid = try angular.fromJson(message.message.replace(/\\\"/g,'\"'))
          catch err
            null

          if bid
            $scope.messages.push
              userid: message.index.account_id,
              username: message.index.account_id
              message: bid.creative.creative.text
              is_mine: is_mine(message.index.account_id, my_account_ids)

  checkMessageFee = (message) ->
    msgSize = Utils.byteLength JSON.stringify(message.message)
    feeRequired = ($scope.chatBid.asset.price + (parseInt( msgSize / 400 ) + 1) * Info.PRECISION) / Info.PRECISION
    return message.amount.amount / Info.PRECISION >= feeRequired

  $scope.setForm = (frm) -> form = frm

  $scope.checkFee = ->
    message = $scope.chatBid.creative.creative.text
    if !message || message == ''
      $scope.feeRequired = 0
      return false

    msgSize = Utils.byteLength JSON.stringify($scope.chatBid)
    $scope.feeRequired = ($scope.chatBid.asset.price + (parseInt( msgSize / 400 ) + 1) * Info.PRECISION) / Info.PRECISION

    if $scope.feeRequired > $scope.from.account.balance.amount / $scope.precision
      form.$setValidity "message", false
      form.message.$error.insufficientFund = true
      console.debug 'not enough balance'
      return false

    return true


  $scope.doSend = ->
    $scope.chatBid.starts_at = Utils.formatUTCDate(new Date())

    unless $scope.checkFee()
      console.debug 'checkFee failed'
      return false

    # do api call
    public_message = JSON.stringify( $scope.chatBid )#.replace(/"/g,'\\\"')
    console.log public_message
    WalletAPI.buy_ad($scope.feeRequired, $scope.symbol, $scope.from.account.account_name, chatAdPositionAcct, public_message).then (response) ->

      $scope.chatBid.creative.creative.text = ''
      form.message.$pristine = true
      form.$pristine = true
      console.log "buy success"
    , (error) ->
        if (error.response.data.error.code == 20010)
            $translate('market.tip.insufficient_balances').then (val) ->
                Growl.notice "", val
        else
            msg = Utils.formatAssertException(error.message)
            Growl.notice "", (if msg?.length > 2 then msg else error.message)

  $scope.post = ->
    $scope.chatBid.creative.creative.text = chat_form.message.value
    $scope.chatBid.starts_at = Utils.formatUTCDate(new Date())

    $scope.doSend()



  if !$scope.symbol and Info.symbol == ''
    Info.refresh_info().then ->
      $scope.symbol = Info.symbol
      init()
  else
    init()
