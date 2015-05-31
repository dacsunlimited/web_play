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

    # fetch last 7 round winners
    $scope.getRecentWinners = (rounds = 7) ->
        console.log 'getRecentWinners'
        blocks_per_day = Info.BLOCKS_PER_DAY
        blocks_per_day = 40 if Info.info.symbol == 'XTS'
        current_block = Info.info.last_block_num
        last_draw_block = parseInt(current_block / blocks_per_day) * blocks_per_day
        $scope.drawing_block_nums = []

        # calculate drawing block numbers
        for i in [0...rounds]
            $scope.drawing_block_nums.push [last_draw_block - i * blocks_per_day]

        # console.log last_draw_block
        console.log 'block_nums', $scope.drawing_block_nums

        # fetch meta
        RpcService.request("batch", ["blockchain_list_operation_reward_transactions", $scope.drawing_block_nums]).then (response) ->
            for i in [0...response.result.length]
                data = response.result[i][0]
                if data
                    data.block_num = $scope.drawing_block_nums[i][0]
                    data.reward.precision = 100000
                    data.reward.symbol = Info.info.symbol
                $scope.recent_winners[i] = data
            console.log 'recent_winners', $scope.recent_winners

    $scope.getRecentWinners()