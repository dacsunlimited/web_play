angular.module("app").filter "simpleFormat", (Utils)->
    (str) ->
        Utils.simpleFormat(str)