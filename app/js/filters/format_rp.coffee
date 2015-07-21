angular.module("app").filter "prettyRP", ($filter) ->
    (rp_number) ->  # TODO
        val = $filter('number')(rp_number / 100000,0)
        return "RP: #{val}"
