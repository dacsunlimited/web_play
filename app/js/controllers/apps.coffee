angular.module("app").controller "AppsController", ($scope) ->
    $scope.apps = [
      { id: "packet", heading: "index.packets", route: 'packets', icon: "fa-envelope", header_image: "/img/header-packets@300.jpg" },
      { id: "notes", heading: "index.notes", route: 'notebooks', icon: "fa-flag", header_image: "/img/header-notes@300.jpg" },
      # { id: "dice", heading: "index.dices", route: 'dice', icon: "fa-flag", header_image: "/img/header-dice@300.jpg" },
      { id: "wheel", heading: "index.wheel", route: 'wheel', icon: "fa-flag", header_image: "/img/header-wheel@300.jpg" },
    ]