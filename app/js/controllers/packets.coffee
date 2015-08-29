angular.module("app").controller "PacketsController", ($scope, $location, $stateParams, $state, Blockchain, Utils, $mdDialog, Observer) ->

  $scope.frm_search =
    id: ""

  $scope.packets =
    created: []
    claimed: []

  $scope.search = ->
    patten = $scope.frm_search.id

    [id, pwd] = patten.split('|')

    Blockchain.get_red_packet(id).then (data) ->
      $scope.search_packet = null

      if data
        $scope.search_packet = data
        $scope.search_packet.password = pwd if pwd
        $scope.form_search_packet.id.$valid = true
        $scope.form_search_packet.id.$error = {}
      else
        $scope.form_search_packet.id.$valid = false
        $scope.form_search_packet.id.$error.notFound = true
    , (err) ->
      $scope.form_search_packet.id.error_message = Utils.formatAssertException(error.data.error.message)

  # get recent packets
  refresh_recent_packets = ->
    Blockchain.refresh_recent_packets().then (result) ->
      if result
        $scope.packets =
          created: result.created?.reverse()
          claimed: result.claimed?.reverse()

  # monitor every block update
  recent_packets_observer =
    name: "recent_packets_observer"
    frequency: "each_block"
    update: (data, deferred) =>
      refresh_recent_packets()
      deferred.resolve(true)

  Observer.registerObserver(recent_packets_observer)
  $scope.$on "$destroy", -> Observer.unregisterObserver(recent_packets_observer)


  $scope.showPacket = (evt, id, pwd = null) ->

    $mdDialog.show
      controller: "PacketController",
      templateUrl: 'packets/packet.show.html',
      parent: angular.element(document.body),
      targetEvent: evt,
      locals:
        id: id
        password: pwd

    .then (succ) ->
      refresh_recent_packets()
    , () ->
      # cancelled, do nothing

  $scope.createpacket = (evt) ->
    $mdDialog.show
      controller: "PacketNewController",
      templateUrl: 'packets/packet.new.html'
      parent: angular.element(document.body)
      targetEvent: evt

    .then (succ) ->
      refresh_recent_packets()
    , () ->
      # cancelled, do nothing



  # init
  refresh_recent_packets()