angular.module("app").controller "WheelController", ($scope, $mdDialog, $stateParams, BlockchainAPI, Observer, Utils, Wallet, $rootScope, RpcService, Info, GameAPI, Growl) ->
  $scope.game_name = 'dice'
  $scope.chip_asset_name = 'DICE'
  $scope.chip_asset = null
  $scope.reveal_block_distance = 10

  # max allowed bet amount, default 1000
  # will be set to current_account's balance when the value is ready
  $scope.bet_max = 1000

  # odds/betting params
  $scope.seg_num = Math.floor(Math.random() * 15) + 2 # minimum 2 seg
  $scope.guess_num = Math.floor(Math.random() * $scope.seg_num) + 2
  $scope.bet_amount = Math.floor(Math.random() * $scope.bet_max)

  $scope.wheel_spinning = false
  $scope.the_wheel = null

  $scope.current_account = null
  $scope.current_account_name = null
  $scope.current_balance = null

  $scope.account_transactions = []

  $scope.buychipForm = null
  $scope.buychip =
    amount: 100

  $scope.betForm = null

  $scope.lastBet = ''

  # store wheel instances, debug purpose
  # disabled for now
  $scope.ws = []

  # initial display
  $scope.$watch 'seg_num', (new_val, old_val) ->
    return if new_val == old_val

    $scope.guess_num = $scope.seg_num if $scope.seg_num < $scope.guess_num

    $scope.drawWheel($scope.seg_num)

  $scope.drawWheel = (seg_num, canvas = 'canvasDisplay')->
    # return if $scope.wheel_spinning

    fill_styles = ['#eae56f','#89f26e','#7de6ef','#e7706f','#eae56f','#89f26e','#7de6ef','#e7706f']
    segments = []
    l = fill_styles.length
    for i in [0...seg_num]
      style = fill_styles[i%l]
      segments.push fillStyle: style, text: (i+1)

    # delele the_wheel if the_wheel?
    wheel = new Winwheel
      'canvasId'     : canvas
      'numSegments'  : seg_num,
      'outerRadius'  : 50,
      'textFontSize' : 9,
      'segments'     : segments,
      'animation' :
        'type'     : 'spinToStop',
        'duration' : 10,
        'spins'    : 15, #the larger the faster
        # 'callbackFinished' : $scope.alertPrize

    wheel.draw()
    wheel


  $scope.spin = (wheel) ->
    return if $scope.wheel_spinning

    # normal spin
    # the_wheel.startAnimation()

    # always make 2 win and spin
    $scope.setPrize(wheel, 5)

    $scope.wheel_spinning = true


  $scope.resetWheel = (wheel)->
    wheel.stopAnimation false  # Stop the animation, false as param so does not call callback function.
    wheel.rotationAngle = 0     # Re-set the wheel angle to 0 degrees.
    wheel.draw()                # Call draw to render changes to the wheel.

    $scope.wheel_spinning = false   # Reset to false to power buttons and spin can be clicked again.

  $scope.setPrize = (wheel, segment_number)->
    return unless segment_number

    wheel.animation.stopAngle = wheel.getRandomForSegment(segment_number)
    wheel.startAnimation()

  $scope.alertPrize = (wheel)->
    # Get the segment indicated by the pointer on the wheel background which is at 0 degrees.
    winning_segment = wheel.getIndicatedSegment()

    # Do basic alert of the segment text. You would probably want to do something more interesting with this information.
    alert("You have won " + winningSegment.text)

  $scope.showPurchaseDialog = (evt) ->
    $mdDialog.show
        parent: angular.element document.body
        scope: $scope
        preserveScope: true
        templateUrl: "wheel/purchase.html"
        targetEvent: evt

  $scope.cancel = ->
      $mdDialog.cancel()

  $scope.hide = ->
      $mdDialog.hide()

  $scope.hotCheckBuyChipAmount = ->
    return $scope.buychip.amount > 0

  $scope.doPurchase = ->
    return false unless $scope.hotCheckBuyChipAmount()

    GameAPI.buy_chips($scope.current_account_name, $scope.buychip.amount, $scope.chip_asset_name).then (response) ->
      # console.log 'purchase success', response
      Growl.notice 'Success', '购买成功'
    , (err) ->
      console.log 'buychip error', err

    $scope.hide()


  $scope.placeBet = ->
    gameParam =
      from_account_name: $scope.current_account_name
      amount: $scope.bet_amount
      odds: $scope.seg_num
      guess: $scope.guess_num

    GameAPI.play($scope.game_name, gameParam).then (resp) ->
      console.log resp

      $scope.current_balance.amount -= gameParam.amount

      refresh_balance()

      Growl.notice "", "下注:#{gameParam.amount}，几率:1/#{gameParam.odds}"
    , (err) ->
      console.log 'play error', err


  $scope.calculate_waiting_blocks = (trx) ->
    return "..." unless trx.is_confirmed

    $scope.reveal_block_distance - (Info.info.last_block_num - trx.block_num)




  refresh_transactions = ->
    Wallet.refresh_transactions().then ->
      return unless Wallet.transactions[$scope.current_account_name]?.length > 0

      # store result transactions temporarily
      checkIds = []
      idBlockMap = {}
      wheels = []

      i = 0
      $scope.account_transactions = Wallet.transactions[$scope.current_account_name].map (trx) ->
        # ledger entry
        lentry = trx.ledger_entries[0]

        # this should be play trx
        if !trx.is_virtual and lentry.to == $scope.current_account_name and lentry.memo == 'play dice'
          checkIds.push trx.block_num

          # construct a map for faster look up
          if !idBlockMap[trx.block_num]
            idBlockMap[trx.block_num] = [i]
          else
            idBlockMap[trx.block_num].push i

          i++
          trx

        else
          null

      .filter (x) ->
        x != null

      # console.log 'account_transactions', $scope.account_transactions.map (x)-> x.block_num
      # console.log 'idBlockMap'
      # for block_num, index of idBlockMap
      #   console.log "#{block_num} => #{index}"

      ids = Utils.unique_array(checkIds).map (x)->[x+$scope.reveal_block_distance]
      # console.log 'ids', ids.map (x)-> x[0]
      RpcService.request('batch', ['game_list_result_transactions', ids]).then (resp) ->
        reveals = resp.result

        l = reveals.length
        if l > 0
          i = 0
          for datas in reveals
            block_num = ids[i]

            j = 0
            trx_ids = idBlockMap[block_num - $scope.reveal_block_distance]
            # console.log 'trx_ids', trx_ids
            while datas.length > 0
              data = datas.shift()

              trx = $scope.account_transactions[trx_ids[j]]
              # console.log 'trx', trx
              trx.reveal = data

              # decide if show wheel effect
              showWheel = $scope.last_block_num - block_num < 2
              wheels.push
                canvasId: "canvas#{trx.id}"
                segment: data.data.odds
                luckyNumber: data.data.lucky_number
                showWheel: showWheel

              # this is the last bet result
              if i == 0 and j == 0
                if data.data.jackpot_received > 0
                  $scope.lastBet = 'win'
                else
                  $scope.lastBet = 'lose'
                # console.log 'lastBet', $scope.lastBet

              j++
            i++

        setTimeout ->
          # console.log 'draw wheels'
          for conf in wheels
            # console.log conf.canvasId
            wheel = $scope.drawWheel(conf.segment, conf.canvasId)
            wheel.animation.stopAngle = wheel.getRandomForSegment(conf.luckyNumber);
            wheel.draw()
            # wheel.startAnimation() if conf.showWheel
            # $scope.ws.push wheel
        , 1000


  BlockchainAPI.get_asset($scope.chip_asset_name).then (asset) ->
    $scope.chip_asset = asset

  # Wallet.get_current_or_first_account().then (acct) ->
  #   $scope.current_account = acct
  #   $scope.current_account_name = acct?.name
  #
  #   refresh_balance()

  $scope.$watch ->
    Wallet.current_account
  , (acct) ->
    $scope.current_account = acct
    $scope.current_account_name = acct?.name

    if acct?.name
      refresh_balance()
      refresh_transactions()

  refresh_balance = ->
    Wallet.refresh_balances().then ->
      $scope.current_balance = Wallet.balances[$scope.current_account_name]?[$scope.chip_asset_name]
      if $scope.current_balance?.amount > 0
        $scope.bet_max = $scope.current_balance.amount / $scope.current_balance.precision
        # if old bet amount overflows, set it to bet max
        $scope.bet_amount = $scope.bet_max if $scope.bet_max < $scope.bet_amount

  block_observer =
    name: "wheel_block_observer"
    frequency: "each_block"
    update: (data, deferred) =>
      refresh_balance()
      refresh_transactions()
      $scope.last_block_num = Info.info.last_block_num

      deferred.resolve(true)
  Observer.registerObserver(block_observer)

  $scope.$on "$destroy", ->
      Observer.unregisterObserver(block_observer)
