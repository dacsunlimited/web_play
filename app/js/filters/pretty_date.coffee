date_params = {timeZone:"UTC",  weekday: undefined, year: "numeric", month: "numeric",  day: "numeric", hour: "numeric", minute: "numeric"}

angular.module("app").filter "prettyDate", (Utils, Wallet)->
    (date, format) ->
        return "-" if !date or date.valueOf() == "1970-01-01T00:00:00"
        format_str = if format == "short" then "L" else "L LT"
        Utils.toLocalDateTime date, format_str, Wallet.timezone

angular.module("app").filter "prettySortableTime", (Utils)->
    (time) ->
        if !time or time.valueOf() == "1970-01-01T00:00:00"
            return {timestamp: Utils.toDate("1970-01-01T00:00:00"), pretty_time: "-"}
        if angular.isDate(time)
            return {timestamp: time, pretty_time: moment(time).format('L LT')}
        else
            return {timestamp: time, pretty_time: moment(Utils.toDate(time)).format('L LT')}

angular.module("app").filter "hoursAgo", (Utils)->
    (date) ->
        if not date
            #console.log "attempting to prettify null date"
            return ""

        if not angular.isDate(date)
            date = Utils.toDate(date)
        diff = Date.now() - date

        diff = Math.round(diff / 1000 / 3600)
        return diff

angular.module("app").filter "secondsAgo", (Utils)->
  (date) ->
    if not date
      #console.log "attempting to prettify null date"
      return "9999999999999"

    if date.valueOf() == "1970-01-01T00:00:00"
      return "9999999999999"

    if not angular.isDate(date)
      date = Utils.toDate(date)
    diff = Date.now() - date

    Math.round(diff / 1000)

angular.module("app").filter "formatSortableExpiration", (Utils)->
  (value) -> value.days

angular.module("app").filter "formatSortableTime", (Utils)->
  (value) -> value.pretty_time

angular.module("app").filter "localTime", (Wallet, Utils)->
    (date) ->
        s = moment().startOf('day')
        e = moment().endOf('day')
        m = Utils.getMoment(date)
        format_str = if m < s or m > e
            'L LT'
          else
            'LT'
        Utils.toLocalDateTime(m, format_str, Wallet.timezone)
