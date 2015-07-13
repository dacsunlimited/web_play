angular.module("app").controller "HomeController", ($scope, $modal, Shared, $log, RpcService, Wallet, BlockchainAPI, Blockchain, Growl, Info, Utils, SecretNote, $timeout, AD) ->
    annoucement_account = Info.ANNOUNCEMENT_ACCT
    ad_account = Info.HOME_AD_POSITION_ACCT

    $scope.announcements = []
    $scope.ads = []

    hlAd = (index) ->
      current = angular.element("ul[rn-carousel] li:eq(#{index})")
      left    = angular.element("ul[rn-carousel] li:eq(#{index - 1})")
      right   = angular.element("ul[rn-carousel] li:eq(#{index + 1})")

      left?.addClass('downgrade')
      right?.addClass('downgrade')
      current?.removeClass('downgrade')

    $scope.$watch "currentIndex", (newValue, oldValue)->
      # index = newValue % 3
      index = if newValue < 3 then newValue else 2
      hlAd(index)

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
    # RpcService.request("batch", ["blockchain_get_account", (ad_accounts.map (a) -> [a])]).then (response) ->
    BlockchainAPI.get_account(ad_account).then (response) ->
        # if it has no ad position set up, skip
        pd = try
            angular.fromJson(response.public_data)
          catch err
            null

        return false unless pd

        # get slide ad bids
        BlockchainAPI.get_account_ads(ad_account, 20).then (results) ->

          i = 0
          for bid in results
            if creative = AD.isValidBid(bid, pd.ad)
              p = Utils.clone(pd)
              p.ad.creative = creative.creative
              $scope.ads[i] = p.ad
              i++

          # if less than 3 valid ads, add default creative
          unless i >= 3
            for j in [i...3]
                $scope.ads[j] = try
                  pd.ad.creative = pd.ad.default_creative
                  pd.ad
                catch err
                  null

          if $scope.ads.length > 0
              $timeout ->
                  hlAd(0)
              , 300
