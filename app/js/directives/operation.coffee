angular.module("app.directives").directive "operationDiv", ($q, Utils, Blockchain) ->
    restrict: "E"
    transclude: true
    template: "<pre ng-transclude></pre>"
    link: (scope, elem, attr) ->
        op = scope.op
        if op.type == "withdraw_op_type"
            scope.content = "Withdraw " + op.data.amount + " satoshi amount of asset"
        else if op.type == "deposit_op_type"
            $q.when(Blockchain.get_asset(op.data.condition.asset_id)).then (asset_type)->
                scope.content = "Deposit " + Utils.formatAsset( Utils.newAsset(op.data.amount, asset_type.symbol, asset_type.precision) )
        else if op.type == "register_account_op_type"
            scope.content = "Register account name: " + op.data.name + " \nwith public data: " + (if op.data.public_data then angular.toJson(op.data.public_data) else "") + ( if op.data.is_delegate then "\nThis account is registered as a delegate" else "")
        else if op.type == "create_asset_op_type"
            scope.content = "Create new asset with symbol " + op.data.symbol + " , the name of this asset is " + op.data.name + ", the detail is " + angular.toJson(op)
        else if op.type == 'note_op_type'
            scope.content = "Spent #{op.data.amount.amount} satoshi amount of asset for creating #{op.data.message.type} note"
        else if op.type == 'red_packet_op_type'
            scope.content = "Create red packet with amount of #{op.data.amount.amount} satoshi"
        else if op.type == 'claim_packet_op_type'
            scope.content = "Claim red packet"
        else
            scope.content = op
