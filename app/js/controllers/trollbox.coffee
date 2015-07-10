angular.module("app").controller "TrollboxController", ($scope, $modal, $log, RpcService, Wallet, WalletAPI, BlockchainAPI, Blockchain, Growl, Info, Utils, Observer, $timeout) ->
  chatAdPositionAcct  = Info.CHAT_ADD_POSITION_ACCT
  chatAdPricingID     = "plain1m"
  chatListLimit       = 50

  adSpec = null
  pricing = null
  $scope.accounts = []
  $scope.registered_accounts = {}
  $scope.from =
    account: null
    isopen: false

  $scope.symbol     = Info.symbol
  $scope.precision  = Info.PRECISION

  $scope.chatBid =
    bidid: "#{chatAdPricingID}"
    creative:
      version: 0.1
      type: 'text'
      creative:
        text: null
    starts_at: null

  $scope.messages = []
  message_trx = []
  $scope.staged_messages = []
  form = null
  skip_once = true

  refresh_balance = ->
    Wallet.refresh_balances().then (balances) ->
      $scope.accounts.splice(0, $scope.accounts.length)
      for account_name, value of balances
        if (balance = value[$scope.symbol]) and $scope.registered_accounts[account_name]
          $scope.accounts.push
            account_name: account_name,
            balance: balance,
            account_id: $scope.registered_accounts[account_name].id
      $scope.from.account = $scope.accounts[0] if $scope.accounts.length > 0

      if skip_once
        skip_once = false
      else
        fetchChatMessages(chatListLimit)

  keep_chat_down = ->
    elem = angular.element('.troll-box')
    elem.scrollTop (elem.get(0).scrollHeight + 550)


  chat_block_observer =
    name: "chat_observer"
    frequency: "each_block"
    update: (data, deferred) ->
      refresh_balance()
      deferred.resolve true

  Observer.registerObserver chat_block_observer
  $scope.$on "$destroy", -> Observer.unregisterObserver(chat_block_observer)


  $scope.$watchCollection ->
      Wallet.accounts
  , ->
      return if Object.keys(Wallet.accounts).length == 0

      # $scope.accounts = Wallet.accounts
      for name, acct of Wallet.accounts
          $scope.registered_accounts[name] = acct if acct.registered

      refresh_balance()


  init = ->
    # get ad position spec
    BlockchainAPI.get_account(chatAdPositionAcct).then (response) ->
      ad_spec = try
        angular.fromJson(response.public_data)
      catch err
        null

      if ad_spec and ad_spec.ad and ad_spec.ad.pricing?.length > 0
        adSpec = ad_spec

        plain1m = ad_spec.ad.pricing.filter (p) -> p.id == chatAdPricingID
        pricing = plain1m[0]


  is_mine = (id, myids) ->
    # console.log id, myids, (id > 0 and myids.indexOf(id) > -1)
    id > 0 and myids.indexOf(id) > -1

  fetchChatMessages = (limit) ->
    new_messages = []
    # get latest chat messages (limit n messages)
    BlockchainAPI.get_account_ads(chatAdPositionAcct, limit).then (response) ->
      if response.length > 0
        my_account_ids = $scope.accounts.map (acct) -> acct.account_id
        # min amount is 200000
        for message in (response.filter (r) -> r.amount.amount >= 200000 and checkMessageFee(r)).reverse()
          bid = try angular.fromJson(message.message.replace(/\\\"/g,'\"'))
          catch err
            null

          # console.log bid.creative.creative.text

          trx_id = message.index.transaction_id

          # if parsing successfully
          # and fresh (not included yet)
          if bid and message_trx.indexOf(trx_id) < 0
            mine = is_mine(message.publisher_id, my_account_ids)

            # if it's my message, find it in staged message and clear it
            if mine and $scope.staged_messages.length > 0
              fp = Utils.hashString bid.creative.creative.text
              foundIndex = ($scope.staged_messages.map (m) -> m.fp).indexOf(fp)
              if foundIndex > -1
                $scope.staged_messages.splice foundIndex, 1

            new_messages.push
              userid:   message.publisher_id,
              username: message.publisher_id
              message:  bid.creative.creative.text
              is_mine:  mine

            message_trx.push trx_id

        # fetch names
        if new_messages.length > 0
          RpcService.request("batch", [ "blockchain_get_account", (new_messages.map (m)-> [m.userid]) ]).then (response) ->
            for i in [0...new_messages.length]
              new_messages[i].username = response.result[i].name

            # concat messages to $scope.messages
            Array::push.apply $scope.messages, new_messages

        $timeout ->
          keep_chat_down()
        , 300

  checkMessageFee = (message) ->
    msgSize = Utils.byteLength JSON.stringify(message.message)
    feeRequired = (pricing.price + (parseInt( msgSize / 400 ) + 1) * Info.PRECISION) / Info.PRECISION
    return message.amount.amount / Info.PRECISION >= feeRequired

  $scope.setForm = (frm) -> form = frm

  $scope.checkFee = ->
    message = $scope.chatBid.creative.creative.text
    if !message || message == ''
      $scope.feeRequired = 0
      return false

    unless $scope.from.account
      form.$setValidity "message", false
      form.message.$error.reg_acct_required = true

    msgSize = Utils.byteLength JSON.stringify($scope.chatBid)
    $scope.feeRequired = (pricing.price + (parseInt( msgSize / 400 ) + 1) * Info.PRECISION) / Info.PRECISION

    if $scope.feeRequired > $scope.from.account.balance.amount / $scope.precision
      form.$setValidity "message", false
      form.message.$error.insufficientFund = true
      return false

    return true


  $scope.doSend = ->
    $scope.chatBid.starts_at = Utils.formatUTCDate(new Date())

    unless $scope.checkFee()
      return false

    # do api call
    public_message = JSON.stringify( $scope.chatBid )#.replace(/"/g,'\\\"')
    console.log public_message
    WalletAPI.buy_ad($scope.feeRequired, $scope.symbol, $scope.from.account.account_name, chatAdPositionAcct, public_message).then (response) ->

      # notify staging
      angular.element('.troll-staging').removeClass('hide')
      $scope.staged_messages.push
        fp: Utils.hashString($scope.chatBid.creative.creative.text),
        message: $scope.chatBid.creative.creative.text

      # reset form
      $scope.chatBid.creative.creative.text = ''
      form.message.$pristine = true
      form.$pristine = true
      # console.log "buy success"

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
