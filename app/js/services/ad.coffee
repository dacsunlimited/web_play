angular.module("app.services").factory "AD", (Utils) ->

  duration2day: (dstr) ->
    [n, num, period] = /([0-9]+)(\w)/.exec(dstr)

    return 0 unless num? && period?
    switch period
      when 'd' then parseInt(num)
      when 'w' then parseInt(num) * 7
      when 'm' then parseInt(num) * 30

  getMessageFee: (message) ->
    msgSize = Utils.byteLength JSON.stringify(message + 10) # deal with marginal length problem
    (parseInt( msgSize / 400 ) + 1)

  isValidBid: (bid, spec) ->
    valid = true
    # match pricing
    pricing_valid = false
    duration = null

    message = try
      angular.fromJson bid.message
    catch error
      null
    return false unless message

    message_fee = @getMessageFee(bid)

    for pricing in spec.pricing
      if pricing.id == message.bid and bid.amount.amount >= (pricing.price + message_fee) && bid.amount.asset_id == 0
        duration = pricing.duration
        pricing_valid = true
        break

    unless pricing_valid
      return false

    # match time range
    now = new Date()
    try
      starts_at = Utils.toDate(message.starts_at)
      # now started yet
      if now < starts_at
        return false

      duration_days = @duration2day(duration)
      ends_at = Utils.toDate Utils.advance_interval(message.starts_at, 60*60*24, duration_days)
      # now it's expired
      if now > ends_at
        return false

    # catch general error
    catch err
      return false

    # TODO
    # check if required field are provided

    return message if valid
