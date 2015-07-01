angular.module("app").controller "HomeController", ($scope, $modal, Shared, $log, RpcService, Wallet, BlockchainAPI, Blockchain, Growl, Info, Utils, SecretNote, $window) ->
    $scope.announcements = []
    annoucement_account = 'bob'
    ad_accounts = ['a.alice', 'b.alice', 'c.alice']
    $scope.ads = []

    # Info.refresh_info().then ->
    #     # TODO this code sucks
    #     satoshi_income = Info.info.income_per_block * (60 * 60 * 24 / 15) #TODO from config
    #     Blockchain.get_asset(0).then (asset_type)->
    #         $scope.daily_income = Utils.formatAsset(Utils.asset(satoshi_income, asset_type)) #TODO
    #         $scope.income_apr = satoshi_income * 365 * 100 / Info.info.share_supply
    #
    #         Blockchain.refresh_delegates().then ->
    #             round_pay_rate = 0
    #             angular.forEach Blockchain.active_delegates, (del) ->
    #                 round_pay_rate += del.delegate_info.pay_rate
    #             satoshi_expenses = satoshi_income * (round_pay_rate / (101 * 100))
    #             $scope.daily_expenses = Utils.formatAsset(Utils.asset(satoshi_expenses, asset_type))
    #             $scope.expenses_apr = satoshi_expenses * 365 * 100 / Info.info.share_supply
    #             $scope.daily_burn = Utils.formatAsset(Utils.asset(satoshi_income - satoshi_expenses, asset_type))
    #             $scope.burn_apr = (satoshi_income - satoshi_expenses) * 365 * 100 / Info.info.share_supply

    # get annoucements
    BlockchainAPI.get_account_notes(annoucement_account).then (results) ->
        $scope.announcements.splice(0, $scope.announcements.length)
        tx_ids = if results
          (results.filter (m) -> m.message.type == 'public_type').map (m) -> m.index.transaction_id
        else
          []

        # decrypt secret note
        RpcService.request("batch_authenticated",
            ["wallet_fetch_note", (tx_ids.map (tx) -> [annoucement_account, tx])]).then (response) ->
            messages = response.result
            for i in [0...messages.length]
                note = SecretNote.decode( 'public_type', messages[i] )
                if note.starts_at and note.expires_at and
                Utils.toDate(note.starts_at) < new Date() and
                Utils.toDate(note.expires_at) > new Date()
                    $scope.announcements[i] = note

    # get ads
    # get ad settings
    RpcService.request("batch", ["blockchain_get_account", (ad_accounts.map (a) -> [a])]).then (response) ->
        pds = response.result.map (acct) ->
          try
            angular.fromJson(acct.public_data)
          catch err
            null

        for i in [0...pds.length]
            $scope.ads[i] = try
              pds[i].ad.creative = pds[i].ad.default_creative
              pds[i].ad
            catch err
              null

    $scope.openAd = (url) ->
        $window.open(url);