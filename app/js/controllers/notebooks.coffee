angular.module("app").controller "NotebooksController", ($scope, Wallet, RpcService, BlockchainAPI, Info, Utils, $state) ->

    $scope.account_names = []
    $scope.pool = {}
    $scope.formatAsset = Utils.formatAsset

    $scope.account_transactions = Wallet.transactions['OP:NOTE']
    $scope.pending_only = false
    $scope.p = {currentPage : 0, pageSize : 20, numberOfPages : 0}
    $scope.q = {}

    $scope.recent_winners = []

    $scope.gotoBook = (account) ->
        if account.registered
          $state.go( 'notes', { name: account.name } )

    Wallet.refresh_accounts().then ->
        accounts = Wallet.accounts
        for item of Wallet.accounts
          $scope.account_names.push
            name: item
            registered: accounts[item].registered

    BlockchainAPI.get_operation_reward('note_op_type').then (results) ->
      $scope.pool = amount: results.fees[0][1], precision: 100000, symbol: Info.info.symbol

    if !Wallet.transactions or Wallet.transactions['*']?.length == 0
        Wallet.refresh_transactions().then ->
            $scope.account_transactions = Wallet.transactions['OP:NOTE']
            # console.log $scope.account_transactions

    next_drawing_block = ->
        $scope.next_drawing_block = (parseInt(Info.info.last_block_num / Info.BLOCKS_PER_DAY) + 1) * Info.BLOCKS_PER_DAY
        # console.log 'drawing block'

    next_drawing_time = ->
        seconds_to_go = (next_drawing_block() - Info.info.last_block_num) * 10
        time = Utils.advance_interval(Info.info.last_block_time, seconds_to_go, 1)
        # console.log 'blocktime', Info.info.last_block_time
        # console.log time
        $scope.next_drawing_time = time

    next_drawing_time()

    # fetch last 7 round winners
    $scope.getRecentWinners = (rounds = 1) ->
        # console.log 'getRecentWinners'
        blocks_per_day = Info.BLOCKS_PER_DAY
        blocks_per_day = 40 if Info.info.symbol == 'XTS'
        current_block = Info.info.last_block_num
        last_draw_block = parseInt(current_block / blocks_per_day) * blocks_per_day
        $scope.drawing_block_nums = []

        # calculate drawing block numbers
        for i in [0...rounds]
            $scope.drawing_block_nums.push [last_draw_block - i * blocks_per_day]

        # console.log last_draw_block
        # console.log 'block_nums', $scope.drawing_block_nums

        # fetch meta
        RpcService.request("batch", ["blockchain_list_operation_reward_transactions", $scope.drawing_block_nums]).then (response) ->
            key_maps = {}
            for i in [0...response.result.length]
                winners = response.result[i]
                for winner in winners
                    winner.block_num = $scope.drawing_block_nums[i][0]
                    winner.reward.precision = 100000
                    winner.reward.symbol = Info.info.symbol
                    unless key_maps[winner.reward_owner]
                      key_maps[winner.reward_owner] = winner.reward_owner
                $scope.recent_winners[i] = winners

            # [[address]]
            key_map_arr = (Object.keys key_maps).map (k) -> [k]
            RpcService.request("batch", ["blockchain_get_account", key_map_arr]).then (response) ->
                # [pubkey]
                pubkeys = []
                for acct in response.result
                    pubkeys.push pubkey: acct.owner_key, name: acct.name

                    for active_key in acct.active_key_history
                        pubkeys.push pubkey: active_key[1], name: acct.name

                pubkeys = Utils.unique_array pubkeys

                RpcService.request("batch", ["debug_public_key_to_address", pubkeys.map (k) -> [k.pubkey]]).then (response) ->
                    for i in [0...response.result.length]
                        addr = response.result[i]
                        pubkeys[i].address = addr

                    key_maps = {}
                    for key in pubkeys
                      key_maps[key.address] = key.name

                    for winners in $scope.recent_winners
                        for winner in winners
                            if key_maps[winner.reward_owner]
                              winner.reward_owner = key_maps[winner.reward_owner]

        # console.log 'recent_winners', $scope.recent_winners

    $scope.getRecentWinners()