angular.module("app").controller "PacketsController", ($scope, $location, $stateParams, $state, Blockchain, BlockchainAPI, Utils, $mdDialog) ->

  $scope.frm_search =
    id: ""

  $scope.packets =
    created: []
    claimed: []

  $scope.search = ->
    patten = $scope.frm_search.id

    [id, pwd] = patten.split('|')

    BlockchainAPI.get_red_packet(id).then (data) ->
      if data
        $scope.search_packet = data
        $scope.search_packet.password = pwd if pwd
        $scope.form_search_packet.id.$valid = true
      else
        $scope.form_search_packet.id.$valid = false
        $scope.form_search_packet.id.$error.notFound = true
    , (err) ->
      $scope.form_search_packet.id.error_message = Utils.formatAssertException(error.data.error.message)

  # get recent packets
  $scope.refresh_recent_packets = ->
    Blockchain.refresh_recent_packets().then (result) ->
      $scope.packets = result

  $scope.showPacket = (evt, id, pwd = null) ->
    # get packet cache from collection
    for p in $scope.packets.created
      packet = p if p.id == id

    unless packet
      for p in $scope.packets.claimed
        packet = p if p.id == id

    $mdDialog.show
      controller: "PacketController",
      templateUrl: 'packets/packet.show.html',
      parent: angular.element(document.body),
      targetEvent: evt,
      locals:
        id: id
        packet: (packet.password = pwd if pwd; packet)

    .then (succ) ->
      $scope.refresh_recent_packets()
    , () ->
      # cancelled, do nothing


  # init
  $scope.refresh_recent_packets()