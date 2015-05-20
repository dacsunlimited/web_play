angular.module("app").controller "NotesController", ($scope, $modal, $stateParams, BlockchainAPI, Blockchain, Utils, Wallet, WalletAPI, $rootScope, RpcService, SecretNote, Info) ->

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
        type: 'private'
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
                $scope.hot_check_send_amount()


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
                note.tx_id      = trxs[i][0]
                note.block_num  = trxs[i][1].chain_location.block_num
                note.timestamp  = trxs[i][1].timestamp

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

    yesSend = ->
        form = @note_form
        message = JSON.stringify(title:$scope.note.title, body:$scope.note.body)
        WalletAPI.note($scope.note.amount, $scope.note.symbol, $scope.note.from, message, $scope.note.type == 'private').then (response) =>

            $scope.note_records.push
                title: $scope.title
                body: $scope.note.body
                type: $scope.note.type
                timestamp: "Just Now"

            for elem in ['title', 'body', 'amount']
                $scope.note[elem] = null
                $scope.note[elem].$setPristine true
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

    $scope.post = ->
        form = @note_form
        symbol = $scope.note.symbol
        amount_asset = Wallet.balances[$scope.note.from][symbol]
        $scope.transfer_amount = Utils.formatDecimal($scope.note.amount, amount_asset.precision) + ' ' + symbol


        WalletAPI.get_transaction_fee(symbol).then (tx_fee) ->
            transfer_asset = Blockchain.symbol2records[symbol]
            Blockchain.get_asset(tx_fee.asset_id).then (tx_fee_asset) ->
                transaction_fee = Utils.formatAsset(Utils.asset(tx_fee.amount, tx_fee_asset))
                trx = {to: $scope.account_name, amount: $scope.transfer_amount, fee: transaction_fee, memo: $scope.note.message, vote: null}
                $modal.open
                    templateUrl: "dialog-transfer-confirmation.html"
                    controller: "DialogTransferConfirmationController"
                    resolve:
                        title: -> "Burn/Post Message Confirmation"
                        trx: -> trx
                        action: -> yesSend
                        transfer_type: ->
                            'burn'


    $scope.cancel = ->
        console.log 'save cancelled'

    $scope.dSend = yesSend

    # Validation and display prior to form submit
    $scope.hot_check_send_amount = ->
        return unless tx_fee
        return unless $scope.balances
        return unless $scope.balances[$scope.account_name]

        message = title:$scope.note.title, body:$scope.note.body
        msgSize = Utils.byteLength( JSON.stringify(message) )
        feeRequired = (tx_fee.amount + (parseInt( msgSize / 1024 ) + 1) * 500000) / tx_fee.precision

        $scope.note.amount = feeRequired
        balance = $scope.balances[$scope.account_name]

        @note_form.$setValidity "amount", balance < feeRequired * tx_fee.precision
        @note_form.amount.$error.insufficientFund = true


        console.log balance, feeRequired

        return true

        my_transfer_form.amount.error_message = null

        if tx_fee.asset_id != $scope.tx_fee_asset.id
            console.log "ERROR hot_check[_send_amount] encountered unlike transfer and fee assets"
            return

        fee=tx_fee.amount/$scope.tx_fee_asset.precision
        transfer_amount=$scope.transfer_info.amount
        _bal=$scope.balances[$scope.transfer_info.symbol]
        balance = _bal.amount/_bal.precision
        balance_after_transfer = balance - transfer_amount
        #display "New Balance 999 (...)"
        $scope.transfer_asset = Blockchain.symbol2records[$scope.transfer_info.symbol]

        if tx_fee.asset_id is $scope.transfer_asset.id
            balance_after_transfer -= fee

        $scope.balance_after_transfer = balance_after_transfer
        $scope.balance = balance
        $scope.balance_precision = _bal.precision
        #transfer_amount -> already available as $scope.transfer_info.amount
        $scope.fee = fee

        my_transfer_form.$setValidity "funds", balance_after_transfer >= 0
        if balance_after_transfer < 0
            my_transfer_form.amount.error_message = "Insufficient funds"
