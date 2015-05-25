angular.module("app").controller "NotesController", ($scope, $mdDialog, $stateParams, BlockchainAPI, Blockchain, Utils, Wallet, WalletAPI, $rootScope, RpcService, Info, SecretNote) ->

    $scope.account_name = $stateParams.name || $rootScope.current_account
    $scope.note_records = []
    $scope.note =
        accounts: []
        # symbols: []
        from: $scope.account_name
        amount: null
        symbol: null
        title: null
        body: null
        type: 'private_type'
    $scope.balances = {}

    tx_fee = null
    form = null

    Info.get().then (result) ->
        # get base symbol
        $scope.note.symbol = result.symbol
        # get transfer fee
        WalletAPI.get_transaction_fee($scope.note.symbol).then (fee) ->
            tx_fee = fee
            Blockchain.get_asset(tx_fee.asset_id).then (_tx_fee_asset) ->
                tx_fee.precision = _tx_fee_asset.precision
                # $scope.hot_check_send_amount()


    BlockchainAPI.get_account_notes($scope.account_name).then (results) ->
        $scope.note_records.splice(0, $scope.note_records.length)
        tx_ids = []
        for r in results
            $scope.note_records.push { type: r.message.type, tx_id: r.index.transaction_id }
            tx_ids.push [r.index.transaction_id]

        # decrypt secret note
        RpcService.request("batch_authenticated",
            ["wallet_fetch_note", (tx_ids.map (tx) -> [$scope.account_name, tx[0]])]).then (response) ->
            messages = response.result
            for i in [0...messages.length]
                note = SecretNote.decode( 'secret_type', messages[i] )
                $scope.note_records[i].note = note

        # fetch meta
        RpcService.request("batch", ["blockchain_get_transaction", tx_ids]).then (response) ->
            trxs = response.result
            blk_nums = []
            for i in [0...trxs.length]
                note = $scope.note_records[i].note
                # debugger unless note?
                note.tx_id      = trxs[i][0]
                note.block_num  = trxs[i][1].chain_location.block_num

                blk_nums[i] = [note.block_num]

            # fetch timestamp
            RpcService.request("batch", ["blockchain_get_block", blk_nums]).then (response) ->
                blks = response.result
                for i in [0...blks.length]
                    note = $scope.note_records[i].note
                    note.timestamp  = blks[i].timestamp


    Wallet.refresh_balances().then (balances) ->
        for account_name, value of balances
            $scope.note.accounts.push(account_name)
            $scope.balances[account_name] =  if value[$scope.note.symbol] then value[$scope.note.symbol].amount else 0


    $scope.showComposeDialog = ->
      $mdDialog.show
          parent: angular.element document.body
          scope: $scope
          templateUrl: "notes/compose.html"

    yesSend = ->
        form = @note_form
        message = JSON.stringify(title:$scope.note.title, body:$scope.note.body)
        WalletAPI.note($scope.note.amount, $scope.note.symbol, $scope.note.from, message, $scope.note.type == 'private').then (response) =>

            $scope.note_records.push
                note:
                  title: $scope.note.title
                  body: $scope.note.body
                  type: $scope.note.type
                  timestamp: "Just Now"
                type: $scope.note.type
                tx_id: null

            for elem in ['title', 'body', 'amount']
                $scope.note[elem] = null
                # $scope.note[elem].$setPristine true

        ,
        (error) ->
            error = error.response if error.response?
            if (error.data?.error.code == 20010)
                form.$error.message = "Insufficient funds"
            else
                errMsg = if error.data? then error.data.error.message else error.message
                msg = Utils.formatAssertException(errMsg)
                form.title.$error.generalError = if msg?.length > 2 then msg else errMsg
                console.log form.title.$error

    $scope.cancel = ->
        $mdDialog.cancel()

    $scope.hide = ->
        $mdDialog.hide()

    $scope.doSend = ->
        yesSend()
        $mdDialog.hide()

    enableForm = (enable) ->
      if enable
        angular.element('#submitNoteBtn').removeAttr 'disabled'
      else
        angular.element('#submitNoteBtn').attr 'disabled', 'disabled'

      enable

    # Validation and display prior to form submit
    $scope.hot_check_send_amount = ->
        return enableForm(false) unless tx_fee?
        return enableForm(false) unless $scope.balances?
        return enableForm(false) unless $scope.balances[$scope.account_name]?
        return enableForm(false) unless ($scope.note.title? && $scope.note.body?)

        message = title:$scope.note.title, body:$scope.note.body
        msgSize = Utils.byteLength( JSON.stringify(message) )
        feeRequired = (tx_fee.amount + (parseInt( msgSize / 1024 ) + 1) * 500000) / tx_fee.precision

        $scope.note.amount = feeRequired
        balance = $scope.balances[$scope.account_name]

        console.log balance, feeRequired
        if balance < feeRequired * tx_fee.precision
          @note_form.$setValidity "amount", false
          @note_form.amount.$error.insufficientFund = true
          return enableForm(false)

        return enableForm(true)