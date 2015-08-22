angular.module("app").controller "AccountController", ($scope, $state, $filter, $location, $stateParams, $window, $q, Growl, Wallet, Utils, WalletAPI, $modal, Blockchain, BlockchainAPI, Info, Observer, $translate) ->

    Info.refresh_info()
    name = $stateParams.name
    $scope.account_name = name
    $scope.utils = Utils
    $scope.formatAsset = Utils.formatAsset
    $scope.model = {}
    $scope.model.rescan = true
    $scope.add_to_address_book = {}

    # tabs
    $scope.tabs = []
    $scope.tabs.push { heading: "account.transactions", route: "account.transactions", active: true, icon: 'fa-list' }
    if $scope.account?.delegate_info
        $scope.tabs.push { heading: "account.delegate_info", route: "account.delegate", active: false, icon: 'fa-legal' }
    # $scope.tabs.push { heading: "account.manageAssets", route: "account.manageAssets", active: false, icon: 'fa-renren' }
    $scope.tabs.push { heading: "account.keys", route: "account.keys", active: false, icon: 'fa-key' }
    $scope.tabs.push { heading: "btn.edit", route: "account.edit", active: false, icon: 'fa-edit' }
    $scope.tabs.push { heading: "account.vote.tab_title", route: "account.vote", active: false, icon: 'fa-ticket' }
    $scope.tabs.push { heading: "account.wall.tab_title", route: "account.wall", active: false, icon: 'fa-comments-o' }

    $scope.getActiveTab = ->
        for i in [0...$scope.tabs.length]
            return i if $state.is $scope.tabs[i].route

        return 0

    $scope.goto_tab = (route) ->
        $state.go route
    $scope.active_tab = (route) -> $state.is route

    $scope.$watch 'selectedIndex', (cur_index, old_index) ->
      cur_index = cur_index or 0

      tab = $scope.tabs[cur_index]
      $scope.goto_tab(tab.route)

    $scope.$on "$stateChangeSuccess", ->
        $scope.selectedIndex = $scope.getActiveTab()

    # $scope.transfer_info =
    #     amount : null
    #     symbol : "Symbol not set"
    #     payto : ""
    #     memo : ""
    #     vote : 'vote_random'

    if $state.current.name == "account"
        $state.go "account.transactions" # first tab

    $scope.memo_size_max = 0
    $scope.private_key = {value : ""}
    $scope.p = { pendingRegistration: Wallet.pendingRegistrations[name] }
    $scope.wallet_info = {file: "", password: "", type: 'Bitcoin/PTS'}

    account_balances_observer =
        name: "account_balances_observer"
        frequency: "each_block"
        update: (data, deferred) ->
            Wallet.refresh_account(name).then (result) ->
                if Wallet.accounts[name] and $scope.account
                    $scope.account.registration_date = Wallet.accounts[name].registration_date
            deferred.resolve(true)

    Wallet.get_account(name).then (acct)->
        $scope.account = acct
        $scope.account.private_data ||= {}
        $scope.account_name = acct.name
        Wallet.set_current_account(acct)
        Observer.registerObserver(account_balances_observer)
        if $scope.account.delegate_info
            update_delegate_info (acct) # update delegate info

        #check if already registered.  this call should be removed when the name conflict info is added to the Wallet.get_account return value
        BlockchainAPI.get_account(name).then (result) ->
            if result and $scope.account.owner_key != result.owner_key
                #Growl.error 'Rename this account to use it', 'Account with the name ' + name + ' is already registered on the blockchian.'
                $modal.open
                    templateUrl: "dialog-rename.html"
                    controller: "DialogRenameController"
                    resolve:
                        oldname: -> name
    , (error) ->
        if error == "not found"
            Wallet.refresh_contacts().then ->
                BlockchainAPI.get_account(name).then (val) ->
                    val = Wallet.contacts[name] unless val
                    account = val
                    account.active_key = val.active_key_history[val.active_key_history.length - 1][1] if val.active_key_history?.length > 0
                    account.registered = val.registration_date and val.registration_date != "1970-01-01T00:00:00"
                    account.is_my_account = false
                    account.is_address_book_contact = !!Wallet.contacts[name]
                    $scope.account = account

                    update_delegate_info() if account.delegate_info


    #Wallet.refresh_account(name)

    Blockchain.get_asset(0).then (asset_type) =>
        $scope.current_xts_supply = asset_type.current_supply

#    $scope.$watch ->
#        Wallet.accounts[name]
#    , ->
#        if Wallet.accounts[name]
#            $scope.account = Wallet.accounts[name]
#            if $scope.account.delegate_info
#                Blockchain.get_asset(0).then (asset_type) ->
#                    $scope.account.delegate_info.pay_balance_asset = Utils.asset($scope.account.delegate_info.pay_balance, asset_type)

    $scope.$watchCollection ->
        Wallet.balances[name]
    , ->
        if Wallet.balances[name]
            $scope.balances = Wallet.balances[name]

#        if Wallet.open_orders_balances[name]
#            $scope.open_orders_balances = Wallet.open_orders_balances[name]
        # if Wallet.bonuses[name]
        #     $scope.bonuses = Wallet.bonuses[name]

        if Wallet.vesting_balances?[name]
            $scope.vesting_balance = Wallet.vesting_balances_summary(name)

#    $scope.$watchCollection ->
#        Wallet.transactions["*"]
#    , () ->
#        Wallet.refresh_account(name)

    $scope.$on "$destroy", ->
        Observer.unregisterObserver(account_balances_observer)

    update_delegate_info = (acct) ->
        requests =
            asset_type: Blockchain.get_asset(0)
            delegates: Blockchain.refresh_delegates()

        $q.all(requests).then (response) ->
            asset_type = response.asset_type
            $scope.account.delegate_info.pay_balance_asset = Utils.asset($scope.account.delegate_info.pay_balance, asset_type)

            if ($scope.account and $scope.account.delegate_info)
                $scope.active_delegate = Blockchain.delegate_active_hash_map[name]
                $scope.rank = Blockchain.all_delegates[name].rank

            $scope.delegate = {}
            if $scope.account.public_data?.delegate?.role >= 0
                $translate('delegate.role_' + $scope.account.public_data.delegate.role).then (role) ->
                    $scope.delegate.role = role

    $scope.vesting_balance_percentage = ->
      if $scope.vesting_balance
        ($scope.vesting_balance.available.amount + $scope.vesting_balance.claimed.amount) / $scope.vesting_balance.vested.amount
      else
        0

    $scope.collect_vested_balance = ->
      if $scope.vesting_balance and $scope.vesting_balance.available?.amount > 0
        WalletAPI.collect_vested_balances($scope.account.name).then (response) ->
          Wallet.refresh_balances()
          $translate('account.claimed', {amount: $scope.vesting_balance.available.amount, symbol: $scope.vesting_balance.available.symbol}).then (val) ->
              Growl.notice "", val
        , (error) ->
          if (error.response.data.error.code == 20010)
              $translate('market.tip.insufficient_balances').then (val) ->
                  Growl.notice "", val
          else
              msg = Utils.formatAssertException(error.message)
              Growl.notice "", (if msg?.length > 2 then msg else error.message)

    $scope.import_key = ->
        form = @import_key_form
        form.key.$invalid = false
        WalletAPI.import_private_key($scope.private_key.value, $scope.account.name, false, $scope.model.rescan).then (response) ->
            $scope.private_key.value = ""
            if response == name
                Growl.notice "", "Your private key was successfully imported."
            else
                Growl.notice "", "Private key already belongs to another account: \"" + response + "\"."
        , (response) ->
            form.key.$invalid = true

    $scope.select_file = ->
        $scope.wallet_info.file = magic_unicorn.prompt_user_to_open_file('Please open your wallet')

    $scope.import_wallet = ->
        form = @import_wallet_form
        form.path.$invalid = false
        form.pass.$invalid = false
        promise = null
        switch $scope.wallet_info.type
            when 'Bitcoin/PTS' then promise = WalletAPI.import_bitcoin($scope.wallet_info.file,$scope.wallet_info.password,$scope.account.name)
            #when 'Multibit' then promise = WalletAPI.import_multibit($scope.wallet_info.file,$scope.wallet_info.password,$scope.account.name)
            when 'Electrum' then promise = WalletAPI.import_electrum($scope.wallet_info.file,$scope.wallet_info.password,$scope.account.name)
            #when 'Armory' then promise = WalletAPI.import_armory($scope.wallet_info.file,$scope.wallet_info.password,$scope.account.name)
            when 'BitShares' then promise = WalletAPI.import_keys_from_json($scope.wallet_info.file,$scope.wallet_info.password,$scope.account.name)
        promise?.then (response) ->
            $scope.wallet_info.type = 'Bitcoin/PTS'
            $scope.wallet_info.file = ""
            $scope.wallet_info.password = ""
            $modal.open
                templateUrl: "dialog-ok.html"
                controller: "DialogOKController"
                resolve:
                    title: -> 'Success'
                    message: -> 'Keys from ' + $scope.wallet_info.type +  ' wallet were successfully imported'
                    bsStyle: -> 'success'
        , (response) ->
            if response.data.error.code == 13 and response.data.error.message.match(/No such file or directory/)
                form.path.error_message = "No such file or directory"
                form.path.$invalid = true
            else if response.data.error.code == 13 and response.data.error.message.match(/Is a directory/)
                form.path.error_message = "This is a directory.  A wallet file is needed."
                form.path.$invalid = true
            else if response.data.error.code == 0 and response.data.error.message.match(/decrypt/)
                form.pass.error_message = "Unable to decrypt wallet"
                form.pass.$invalid = true
            else
                $modal.open
                    templateUrl: "dialog-ok.html"
                    controller: "DialogOKController"
                    resolve:
                        title: -> 'Error'
                        message: -> response.data.error.message
                        bsStyle: -> 'danger'

    $scope.toggleVoteUp = ->
        newApproval=1
        if ($scope.account.approved>0)
            newApproval=-1
        if ($scope.account.approved<0)
            newApproval=0
        Wallet.approve_account(name, newApproval).then ->
            $scope.account.approved=newApproval

    $scope.regDial = ->
        $modal.open
            templateUrl: "registration.html"
            controller: "RegistrationController"
            scope: $scope

    $scope.link = (address) ->
        $window.open(address)
        return true

    $scope.addToAddressBook = ->
        error_handler = (error) ->
            message = Utils.formatAssertException(error.data.error.message)
            $scope.add_to_address_book.error = if message and message.length > 2 then message else "Unknown account"

        WalletAPI.add_contact($scope.account.active_key, $scope.account.name, error_handler).then ->
            Wallet.refresh_contacts().then ->
                account = Wallet.contacts[name]
                if account
                    $scope.account.is_address_book_contact = true
                    account.is_address_book_contact = true
                    Wallet.contacts[name] = account
                    $scope.add_to_address_book.message = "Added to address book"
                else
                    $scope.add_to_address_book.error = "Unknown account"
            , (error) ->
                $scope.add_to_address_book.error = Utils.formatAssertException(error.data.error.message)
