angular.module("app").controller "MyPacketSearchController", ($scope, $location, $stateParams, $state, Blockchain, Wallet, Utils, $mdDialog, Observer, RpcService, account_id) ->

  # get recent packets
  refresh_my_packets = (acct_id) ->
    Wallet.list_red_packets(acct_id).then (packets) ->
      if packets and packets.length > 0

        # my created packets' ids
        ids = (packets.filter (p)-> p.is_sender ).map (p)-> [p.packet_id]

        RpcService.request('batch', ['blockchain_get_red_packet', ids]).then (response) ->
          ps = response.result
          for i in [0...ps.length]
            ps[i].is_sender   = packets[i].is_sender
            ps[i].is_claimer  = packets[i].is_claimer
            ps[i].index       = packets[i].index

            ps[i].slots_count   = ps[i].claim_statuses.length
            ps[i].claimed_count = (ps[i].claim_statuses.filter (s) -> s.account_id > -1).length

            asset = Blockchain.asset_records[ps[i].amount.asset_id]
            ps[i].amount.precision = asset?.precision
            ps[i].amount.symbol    = asset?.symbol

          $scope.packets = ps
          console.log $scope.packets[0]

  $scope.select_packet = (packet) ->
    $mdDialog.hide(packet)

  $scope.hide = ->
    $mdDialog.hide()
  $scope.cancel = ->
    $mdDialog.cancel()

  # init
  refresh_my_packets(account_id || Wallet.current_account?.id)