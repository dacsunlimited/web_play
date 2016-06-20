angular.module("app").controller "DColorBallController", ($scope, $mdDialog, $stateParams, BlockchainAPI, Observer, Utils, Wallet, $rootScope, RpcService, Info, GameAPI, Growl) ->
  $scope.game_name = 'dice'
  $scope.chip_asset_name = 'DICE'
  # the name within play trx memo, if multiple games share one contract
  # this needs to be set and it's probably different from game name
  $scope.memo_game_name = 'dice'
  $scope.chip_asset = null
  $scope.chip_price = null
  $scope.reveal_block_distance = 10

  # game modes
  # support 3 different static modes at the moment
  # red balls:
  #   1. 2 / 5
  #   2. 5 / 10
  #   3. 5 / 15
  # blue balls:
  #   always select 1 blue ball
  #   1 / 4
  modes =
    "2/5":
      label:      "2/5",
      red:        [2,5],
      blue:       [1,4],

    "5/10":
      label:      "5/10",
      red:        [5,10],
      blue:       [1,4],

    "5/15":
      label:      "5/15",
      red:        [5,15],
      blue:       [1,4],

  # compute Ns
  for section, mode of modes
    mode.red_n  = Combinatorics.C(mode.red[1], mode.red[0])
    mode.blue_n = Combinatorics.C(mode.blue[1], mode.blue[0])
    mode.combined_n = mode.red_n * mode.blue_n

  # game mode list
  $scope.gameModes = modes

  # default mode
  $scope.currentMode = "2/5";

  # max allowed bet amount, default 1000
  # will be set to current_account's balance when the value is ready
  $scope.bet_max = 1000

  # user selection
  # [[red selections], [blue selections]]
  $scope.selections =
    red: [],
    blue: []

  # odds/betting params
  $scope.seg_num = Math.floor(Math.random() * 15) + 2 # minimum 2 seg
  $scope.guess_num = Math.floor(Math.random() * $scope.seg_num) + 2
  $scope.bet_amount = Math.floor(Math.random() * $scope.bet_max)

  $scope.current_account = null
  $scope.current_account_name = null
  $scope.current_balance = null
  $scope.current_core_balance = null

  $scope.account_transactions = []

  $scope.buychipForm = null
  $scope.buychip =
    amount: 1000

  $scope.betForm = null

  $scope.lastBet = ''

  # store wheel instances, debug purpose
  # disabled for now
  $scope.ws = []

  # initial display
  $scope.$watch 'currentMode', (new_val, old_val) ->
    return if new_val == old_val

    $scope.setGameMode(new_val)

  $scope.setGameMode = (mode) ->
    return unless mode && $scope.gameModes[mode]

    $scope.currentMode = mode
    $scope.ballNumbers = [
      [1..$scope.gameModes[$scope.currentMode].red[1]],
      [1..$scope.gameModes[$scope.currentMode].blue[1]]
    ]

    $scope.clearSelections()


  $scope.getNumbers = (section) ->
    return $scope.ballNumbers[$scope.getSectionId(section)]

  $scope.getSectionId = (section) ->
    return if section == 'red' then 0 else 1

  $scope.userSelect = (section, num) ->
    selected = $scope.selections[section]

    # toggle selection
    if (index = selected.indexOf(num)) != -1
      selected.splice(index, 1)
    else
      selected.push(num)

    $scope.selections[section] = selected

  # check if user selected this num
  $scope.userSelected = (section, numToCheck) ->
    selected = $scope.selections[section]

    return selected.indexOf(numToCheck) != -1


  $scope.randSelect = (section) ->
    [reqNum, total] = $scope.gameModes[$scope.currentMode][section]
    rands           = Utils.shuffleArray([1..total])[0...reqNum]

    $scope.selections[section] = rands


  $scope.clearSelection = (section) -> $scope.selections[section] = []
  $scope.clearSelections = -> $scope.selections = red:[], blue:[]

  $scope.alertPrize = (wheel)->
    # Get the segment indicated by the pointer on the wheel background which is at 0 degrees.
    winning_segment = wheel.getIndicatedSegment()

    # Do basic alert of the segment text. You would probably want to do something more interesting with this information.
    alert("You have won " + winningSegment.text)

  # decide min bet amount
  $scope.getMinBetAmount = ->
    unless $scope.current_balance
      100
    else
      Math.min(100, parseInt($scope.current_balance.amount / $scope.current_balance.precision) / 20)

  # make step for 20 rounds
  $scope.getBetStep = ->
    unless $scope.current_balance
      100
    else
      parseInt($scope.current_balance.amount / $scope.current_balance.precision / 20)

  $scope.showPurchaseDialog = (evt) ->
    $mdDialog.show
        parent: angular.element document.body
        scope: $scope
        preserveScope: true
        templateUrl: "wheel/purchase.html"
        targetEvent: evt
    .then ->
      $scope.fetchGameAssetPrice()

  $scope.cancel = ->
      $mdDialog.cancel()

  $scope.hide = ->
      $mdDialog.hide()

  $scope.fetchGameAssetPrice = ->
    BlockchainAPI.get_asset($scope.chip_asset_name).then (asset) ->
      return 0 unless asset && asset.current_collateral && asset.current_supply
      $scope.chip_asset = asset
      $scope.chip_price = Utils.formatDecimal((asset.current_collateral / ($scope.current_core_balance?.precision || 5)) / (asset.current_supply / asset.precision), 2)

  $scope.hotCheckBuyChipAmount = ->
    return $scope.buychip.amount > 0

  $scope.doPurchase = ->
    return false unless $scope.hotCheckBuyChipAmount()

    GameAPI.buy_chips($scope.current_account_name, $scope.buychip.amount, $scope.chip_asset_name).then (response) ->
      Growl.notice 'Success', '购买成功'
    , (err) ->
      error = err.data?.error || err.response?.data?.error
      error_message = error.locale_message || error.message
      Growl.error "", error_message

    $scope.hide()

  $scope.getOdds = ->
    # return current game mode's n
    # could be pre-calculated
    $scope.gameModes[$scope.currentMode].combined_n

  # # forward rank
  # rank = red_rank * blue_n + blue_rank
  $scope.getRanking = ->
    red_rank  = Utils.ranking( $scope.selections.red )
    blue_rank = Utils.ranking( $scope.selections.blue ) || 0
    blue_n = $scope.gameModes[$scope.currentMode].blue_n

    rank = red_rank * blue_n + blue_rank

  # # unrank
  # red_rank = (rank / blue_n).to_i
  # blue_rank = rank % blue_n
  $scope.revealResult = (rank, odds) ->
    gameMode = $scope.getGameFromOdds(odds)
    red_rank  = parseInt(rank / gameMode.blue_n)
    blue_rank = rank % gameMode.blue_n

    return {
      red:  Utils.unranking(red_rank, gameMode.red[0], gameMode.red[1]).map (x) -> x + 1
      blue: Utils.unranking(blue_rank, gameMode.blue[0], gameMode.blue[1]).map (x) -> x + 1
    }

  $scope.getGameFromOdds = (odds) ->
    for section, mode of $scope.gameModes
      if mode.combined_n == odds
        return mode

  $scope.betted = ->
    $scope.selections.red.length == parseInt($scope.currentMode.split('/')[0]) &&
    $scope.selections.blue.length == 1

  $scope.placeBet = ->
    gameParam =
      from_account_name: $scope.current_account_name
      amount: $scope.bet_amount
      odds:   $scope.getOdds()
      guess:  $scope.getRanking()

    console.log "placeBet:", JSON.stringify(gameParam)
    GameAPI.play($scope.game_name, gameParam).then (resp) ->
      console.log resp

      $scope.current_balance.amount -= gameParam.amount * $scope.current_balance.precision

      refresh_balance()
      $scope.clearSelections()

      Growl.notice "", "下注:#{gameParam.amount}，几率:1 / #{gameParam.odds}"
    , (err) ->
      error = err.data?.error || err.response?.data?.error
      error_message = error.locale_message || error.message
      Growl.error "", error_message


  $scope.calculate_waiting_blocks = (trx) ->
    return "..." unless trx.is_confirmed

    $scope.reveal_block_distance - (Info.info.last_block_num - trx.block_num)


  refresh_transactions = ->
    console.log 'refresh_transactions'
    Wallet.refresh_transactions().then ->
      return unless Wallet.transactions[$scope.current_account_name]?.length > 0

      # store result transactions temporarily
      checkIds = []
      checkTrx = []
      idBlockMap = {}

      i = 0
      $scope.account_transactions = Wallet.transactions[$scope.current_account_name].map (trx) ->
        # ledger entry
        lentry = trx.ledger_entries[0]

        # this should be play trx
        if !trx.is_virtual and lentry.to == $scope.current_account_name and lentry.memo == "play #{$scope.memo_game_name}"
          checkIds.push trx.block_num
          checkTrx.push trx.id

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
      trxes = Utils.unique_array(checkTrx).map (x)->[x]

      RpcService.request('batch', ['blockchain_get_transaction', trxes]).then (resp) ->
        l = resp.result.length
        if l > 0
          i = 0
          for trx_data in (resp.result.map (x) -> x[1])
            bet = -1
            for op in trx_data.trx.operations
              if op.type == 'game_play_op_type'
                bet = op.data.input.data
                block_num = trx_data.chain_location.block_num
                trx_ids = idBlockMap[block_num]
                trx = $scope.account_transactions[trx_ids[0]]
                if bet != -1
                  trx.bet = bet
                  trx.bet.combination = $scope.revealResult(bet.guess, bet.odds)
                break
            i++

      RpcService.request('batch', ['game_list_result_transactions', ids]).then (resp) ->
        reveals = resp.result

        game_ns = []
        game_ns.push mode.combined_n for section, mode of $scope.gameModes

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

              # check if this belongs to this game's odds
              if (game_ns.indexOf(data.data.odds) == -1)
                $scope.account_transactions.splice(trx_ids[j],1)
                break

              trx = $scope.account_transactions[trx_ids[j]]
              trx.reveal = data
              trx.reveal.combination = $scope.revealResult(data.data.lucky_number, data.data.odds)

              # this is the last bet result
              if i == 0 and j == 0
                if data.data.jackpot_received > 0
                  $scope.lastBet = 'win'
                else
                  $scope.lastBet = 'lose'
                # console.log 'lastBet', $scope.lastBet

              j++
            i++


  BlockchainAPI.get_asset($scope.chip_asset_name).then (asset) ->
    $scope.chip_asset = asset

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
      $scope.current_core_balance = Wallet.balances[$scope.current_account_name]?[Info.info.symbol]
      $scope.current_balance = Wallet.balances[$scope.current_account_name]?[$scope.chip_asset_name]
      if $scope.current_balance?.amount > 0
        $scope.bet_max = $scope.current_balance.amount / $scope.current_balance.precision
        # if old bet amount overflows, set it to bet max
        $scope.bet_amount = $scope.bet_max if $scope.bet_max < $scope.bet_amount
      else
        $scope.bet_max = 0
        $scope.bet_amount = 0

      $scope.fetchGameAssetPrice()

  block_observer =
    name: "dice_block_observer"
    frequency: "each_block"
    update: (data, deferred) =>
      refresh_balance()
      refresh_transactions()
      $scope.last_block_num = Info.info.last_block_num

      deferred.resolve(true)
  Observer.registerObserver(block_observer)

  $scope.$on "$destroy", ->
      Observer.unregisterObserver(block_observer)
