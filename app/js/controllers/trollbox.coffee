angular.module("app").controller "TrollboxController", ($scope, $modal, $log, $q, RpcService, Wallet, WalletAPI, BlockchainAPI, Blockchain, Growl, Info, Utils, Observer, $timeout, $mdDialog, AD) ->
  chatAdPositionAcct    = Info.CHAT_ADD_POSITION_ACCT


  textPriceID           = "plain1m"
  packetPriceID         = "packet1m"

  chatListLimit         = 50
  chatSepBlockInterval  = 120 # 2 minutes

  adSpec = null
  pricing = null
  pricings = {}
  $scope.accounts = []
  $scope.registered_accounts = {}
  $scope.from =
    account: null
    isopen: false

  $scope.symbol     = Info.symbol
  $scope.precision  = Info.PRECISION

  # plain text chat
  $scope.chatBid =
    bidid: "#{textPriceID}"
    creative:
      version: 0.1
      type: 'text'
      creative:
        text: null
    starts_at: null

  # packet chat
  $scope.packetBid =
    bidid: "#{packetPriceID}"
    creative:
      version: 0.1
      type: 'packet'
      creative:
        id: null
    starts_at: null

  $scope.messages = []
  message_trx = []
  $scope.staged_messages = []
  form = null
  skip_once = true

  trollbox_ui = '#troll_box'
  current_scrollHeight = 0 # message panel height

  refresh_balance = ->
    Wallet.refresh_balances().then (balances) ->
      $scope.accounts.splice(0, $scope.accounts.length)
      for account_name, value of balances
        if (balance = value[$scope.symbol]) and $scope.registered_accounts[account_name]
          $scope.accounts.push
            account_name: account_name,
            balance: balance,
            account_id: $scope.registered_accounts[account_name].id

      # determine default chat account
      # try to fetch from Wallet.current_account, otherwise, use the first account of
      # avaialble accounts (registered and with balance)
      unless $scope.from.account
        $scope.from.account = $scope.accounts[0] if $scope.accounts.length > 0

        if Wallet.current_account and (foundIndex = ($scope.accounts.findIndex (acct)-> acct.account_name == Wallet.current_account.name))
          $scope.from.account = $scope.accounts[foundIndex]


      if skip_once
        skip_once = false
      else
        fetchChatMessages(chatListLimit)

  keep_chat_down = ->
    elem = angular.element( trollbox_ui )
    elem_dom = elem.get(0)
    clientHeight = elem_dom.clientHeight
    current_scrollTop = elem.data 'current_scrollTop'

    # initially delta should be treated as zero
    if current_scrollHeight == 0
      deltaSH = 0
    else
      deltaSH = elem_dom.scrollHeight - current_scrollHeight

    # if user is viewing last few lines, we show new contents
    position2bottom = current_scrollHeight - clientHeight - current_scrollTop
    if !current_scrollTop || position2bottom < 160 #average line_item height ((60+20) * 2)
        checkpoint = elem_dom.scrollHeight - clientHeight - (if deltaSH < clientHeight then 0 else deltaSH)
        elem_dom.scrollTop = checkpoint

    elem.data 'current_scrollTop', elem_dom.scrollTop if elem_dom.scrollTop > current_scrollTop
    current_scrollHeight  = elem_dom.scrollHeight if elem_dom.scrollHeight > current_scrollHeight


  chat_block_observer =
    name: "chat_observer"
    frequency: "each_block"
    update: (data, deferred) ->
      refresh_balance()
      deferred.resolve true

  Observer.registerObserver chat_block_observer
  $scope.$on "$destroy", ->
    Observer.unregisterObserver(chat_block_observer)
    angular.element( trollbox_ui ).off 'scroll'

  $scope.$watchCollection ->
      Wallet.accounts
  , ->
      return if Object.keys(Wallet.accounts).length == 0

      # $scope.accounts = Wallet.accounts
      for name, acct of Wallet.accounts
          $scope.registered_accounts[name] = acct if acct.registered

      refresh_balance()


  init = ->
    angular.element( trollbox_ui ).on 'scroll', (evt) ->
      elem = angular.element( trollbox_ui )
      elem.data 'current_scrollTop', elem.get(0).scrollTop

    # get ad position spec
    BlockchainAPI.get_account(chatAdPositionAcct).then (response) ->
      ad_spec = try
        angular.fromJson(response.public_data)
      catch err
        null

      if ad_spec and ad_spec.ad and ad_spec.ad.pricing?.length > 0
        adSpec = ad_spec

        plain1m = ad_spec.ad.pricing.filter (p) -> p.id == textPriceID
        pricing = plain1m[0]

        for p in ad_spec.ad.pricing
          pricings[p.id] = p

  # based on bid type, return descriptiontive message, eg text or id
  getBidMsg = (bid) ->
    switch bid.creative.type
      when 'text'
        bid.creative.creative.text
      when 'packet'
        bid.creative.creative.id
      else
        bid.creative.creative.text

  is_mine = (id, myids) ->
    # console.log id, myids, (id > 0 and myids.indexOf(id) > -1)
    id > 0 and myids.indexOf(id) > -1

  fetchChatMessages = (limit) ->
    new_messages = []
    # get latest chat messages (limit n messages)
    BlockchainAPI.get_account_ads(chatAdPositionAcct, limit).then (response) ->
      if response?.length > 0
        my_account_ids = $scope.accounts.map (acct) -> acct.account_id
        # min amount is 200000
        for message in response.reverse() #(response.filter (r) -> checkMessageFee(r)).reverse()
          bid = try angular.fromJson(message.message.replace(/\\\"/g,'\"'))
          catch err
            null

          # if json parse error or didn't pay enough fee, skip
          continue unless bid && checkMessageFee(bid.bidid, message)

          trx_id = message.index.transaction_id

          # if parsing successfully
          # and fresh (not included yet)
          if bid and message_trx.indexOf(trx_id) < 0
            mine = is_mine(message.publisher_id, my_account_ids)

            # if it's my message, find it in staged message and clear it
            if mine and $scope.staged_messages.length > 0
              fp = Utils.hashString getBidMsg(bid)
              foundIndex = ($scope.staged_messages.map (m) -> m.fp).indexOf(fp)
              if foundIndex > -1
                $scope.staged_messages.splice foundIndex, 1

            new_messages.push
              userid:   message.publisher_id
              username: message.publisher_id
              rp: null
              # message:  bid.creative.creative.text
              creative: bid.creative
              timestamp: bid.starts_at
              is_mine:  mine
              txid:     trx_id
              block_num: null
              trx_num:  0
              is_fresh: false

            message_trx.push trx_id

        # fetch names
        if new_messages.length > 0
          requests =
            accts: RpcService.request("batch", [ "blockchain_get_account", (new_messages.map (m)-> [m.userid]) ])
            trxs:  RpcService.request("batch", [ "blockchain_get_transaction", (new_messages.map (m)-> [m.txid]) ])

          packet_messages = new_messages.filter (m) -> m.creative.type == 'packet'
          if packet_messages.length > 0
            requests.packets = Blockchain.get_red_packets(packet_messages.map (m)-> m.creative.creative.id)

          $q.all(requests).then (response) ->
            accts = response.accts.result
            trxs  = response.trxs.result
            packets = response.packets

            for i in [0...new_messages.length]
              msg = new_messages[i]
              acct  = accts[i]
              chain = trxs[i][1].chain_location

              msg.username  = acct.name
              msg.rp        = acct.stats_info.rp
              msg.block_num = chain.block_num
              msg.trx_num   = chain.trx_num

              msg.is_fresh = (i == 0 or (i > 0 and chain.block_num - new_messages[i-1].block_num > chatSepBlockInterval))

            # packets
            if packets?.length > 0
              # packets mapping
              packets_mapping = {}
              for p in packets
                packets_mapping[p.id] = p

              for msg in new_messages
                if msg.creative.type == 'packet'
                  msg.creative.creative.packet = packets_mapping[msg.creative.creative.id]

              packets_mapping = null

            # sort message by block_num, trx_num
            new_messages

            Array::push.apply $scope.messages, new_messages

            $timeout ->
              keep_chat_down()
            , 300

  getRequiredFee = (bidid, bidJSON) ->
    # if bidid is not identified, give a large enough price
    # so that it will fail and be skipped
    bid_price = pricings[bidid]?.price || 100000000

    (bid_price + AD.getMessageFee(bidJSON) * Info.PRECISION) / Info.PRECISION

  checkMessageFee = (bidid, message) ->
    # msgSize = Utils.byteLength JSON.stringify(message.message) - 20 # deal with marginal length problem
    feeRequired = getRequiredFee(bidid, message.message)

    return message.amount.amount / Info.PRECISION >= feeRequired

  $scope.setForm = (frm) -> form = frm

  $scope.checkFee = (bid)->
    message = getBidMsg(bid)
    if !message || message == ''
      $scope.feeRequired = 0
      return false

    unless $scope.from.account
      form.$setValidity "message", false
      form.message.$error.reg_acct_required = true

    $scope.feeRequired = getRequiredFee(textPriceID, bid)

    if $scope.feeRequired > $scope.from.account.balance.amount / $scope.precision
      form.$setValidity "message", false
      form.message.$error.insufficientFund = true
      return false

    return true

  $scope.doSend = (bid) ->
    bid.starts_at = Utils.formatUTCDate(new Date())

    unless $scope.checkFee(bid)
      return false

    # do api call
    public_message = JSON.stringify( bid )#.replace(/"/g,'\\\"')
    WalletAPI.buy_ad($scope.feeRequired, $scope.symbol, $scope.from.account.account_name, chatAdPositionAcct, public_message).then (response) ->

      # notify staging
      angular.element('.troll-staging').removeClass('hide')
      msg = getBidMsg(bid)
      $scope.staged_messages.push
        fp: Utils.hashString( msg ),
        message: msg.substr(0,20)

      # reset form
      $scope.chatBid.creative.creative.text = null
      $scope.packetBid.creative.creative.id = null
      form.message.$dirty = false

    , (err) ->
        error = err.data?.error || err.response?.data?.error
        if (error.code == 20010)
            $translate('market.tip.insufficient_balances').then (val) ->
                Growl.notice "", val
        else
            msg = Utils.formatAssertException(error.message)
            Growl.notice "", (if msg?.length > 2 then msg else error.message)

  $scope.post = ->
    $scope.chatBid.creative.creative.text = chat_form.message.value
    $scope.chatBid.starts_at = Utils.formatUTCDate(new Date())

    $scope.doSend($scope.chatBid)

  $scope.showSearchPakcetDialog = (evt) ->
    $mdDialog.show
      controller: "MyPacketSearchController"
      templateUrl: 'packets/packets.my.search.html'
      parent: angular.element(document.body)
      targetEvent: evt
      clickOutsideToClose:true
      locals:
        account_id: $scope.from.account.account_id

    .then (packet) ->
      if packet
        console.log 'searchPacketDialog successfully submitted'
        console.log 'packet', packet

        $scope.packetBid.creative.creative.id = packet.id
        $scope.packetBid.starts_at = Utils.formatUTCDate(new Date())

        $scope.doSend($scope.packetBid)
    , () ->
      # cancelled, do nothing

  $scope.showPacket = (evt, id, pwd = null) ->

    $mdDialog.show
      controller: "PacketController"
      templateUrl: 'packets/packet.show.html'
      parent: angular.element(document.body)
      targetEvent: evt
      clickOutsideToClose:true
      locals:
        id: id
        password: pwd

    .then (succ) ->
      # TODO
      # update specific packet message
      console.log 'packet claimed', succ
    , () ->
      # cancelled, do nothing

  if !$scope.symbol and Info.symbol == ''
    Info.refresh_info().then ->
      $scope.symbol = Info.symbol
      init()
  else
    init()
