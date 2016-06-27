angular.module("app").filter "formatAsset", (Utils)->
    (asset) ->
        Utils.formatAsset(asset)

angular.module("app").filter "formatAssetPrice", (Utils)->
    (asset) -> Utils.formatAssetPrice(asset)

angular.module("app").filter "formatMoney", (Utils)->
    (asset) -> Utils.formatMoney(asset)

angular.module("app").filter "formatDecimal", (Utils)->
    (asset, decimals, truncate0s) -> Utils.formatDecimal(asset, decimals, truncate0s)

angular.module("app").filter "formatAccountBalance", (Blockchain, Utils) ->
  (account, filterSymbol) ->
    result = account[0] + " | "
    balances = []
    for balance in account[1]
      # if filterSymbol is provided and not match, skip balance
      continue if filterSymbol and balance.symbol != filterSymbol

      balances.push Utils.formatAsset(balance)

    result + balances.join('; ')
