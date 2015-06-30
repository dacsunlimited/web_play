servicesModule = angular.module("app.services")

servicesModule.factory "Growl", ($mdToast) ->
  toastPosition: "right top"
  fadeTime: 3000

  error: (title, message) ->
    # jQuery.growl.error(title: title, message: message)
    this.showToast('error', title, message)

  notice: (title, message) ->
    # jQuery.growl.notice(title: title, message: message)
    this.showToast('notice', title, message)

  warning: (title, message) ->
    # jQuery.growl.warning(title: title, message: message)
    this.showToast('warning', title, message)

  #TODO: show custom template with notice level differed
  showToast: (type, title, message) ->
    $mdToast.show(
      $mdToast.simple()
      .content("#{message}")
      .position(this.toastPosition)
      .hideDelay(this.fadeTime)
    )

