angular.module("app").config ($stateProvider, $urlRouterProvider, $locationProvider) ->

    base_tag = document.getElementsByTagName('base')[0]
    prefix = if base_tag then base_tag.getAttribute("href") else ""

    # relative url app version support
    $locationProvider.html5Mode(true) if prefix

    sp = $stateProvider
    $urlRouterProvider.otherwise prefix + '/home'

    sp.state "home",
        url: "/home"
        templateUrl: "home.html"
        controller: "HomeController"

    sp.state "help",
        url: "/help"
        templateUrl: "help.html"
        controller: "HelpController"

    sp.state "preferences",
        url: prefix + "/preferences"
        templateUrl: "advanced/preferences.html"
        controller: "PreferencesController"

    sp.state "console",
        url: prefix + "/console"
        templateUrl: "advanced/console.html"
        controller: "ConsoleController"

    sp.state "wallet",
        url: prefix + "/wallet"
        templateUrl: "wallet.html"
        controller: "WalletController"

    sp.state "create/account",
        url: prefix + "/create/account"
        templateUrl: "createaccount.html"
        controller: "CreateAccountController"

    sp.state "accounts",
        url: prefix + "/accounts"
        templateUrl: "accounts.html"
        controller: "AccountsController"

    sp.state "directory",
        url: "/directory"
        templateUrl: "directory/directory.html"
        controller: "DirectoryController"

    sp.state "directory.favorites", { url: "/favorites", views: { 'directory-favorites': { templateUrl: 'directory/favorite.html', controller: 'FavoriteController' } } }

    sp.state "directory.unregistered", { url: "/unregistered", views: { 'directory-unregistered': { templateUrl: 'contacts.html', controller: 'ContactsController' } } }

    sp.state "directory.registered", { url: "/registered?letter", views: { 'directory-registered': { templateUrl: 'directory/registered.html' } } }

    sp.state "directory.assets", { url: "/assets", views: { 'directory-assets': { templateUrl: 'directory/assets.html', controller: 'AssetsController' } } }

    sp.state "delegates",
        url: prefix + "/delegates"
        templateUrl: "delegates/delegates.html"
        controller: "DelegatesController"

    sp.state "account",
        url: prefix + "/accounts/:name"
        templateUrl: "account.html"
        controller: "AccountController"

    sp.state "account.transactions", { url: "/account_transactions?pending_only", views: { 'account-transactions': { templateUrl: 'account_transactions.html', controller: 'TransactionsController' } } }

    sp.state "account.delegate", { url: "/account_delegate", views: { 'account-delegate': { templateUrl: 'account_delegate.html', controller: 'AccountDelegate' } } }

    sp.state "account.transfer", { url: "/account_transfer?from&to&amount&memo&asset", views: { 'account-transfer': { templateUrl: 'transfer.html', controller: 'TransferController' } } }

    sp.state "account.manageAssets", { url: "/account_assets", views: { 'account-manage-assets': { templateUrl: 'manage_assets.html', controller: 'ManageAssetsController' } } }

    sp.state "account.keys", { url: "/account_keys", views: { 'account-keys': { templateUrl: 'account_keys.html' } } }

    sp.state "account.edit", { url: "/account_edit", views: { 'account-edit': { templateUrl: 'account_edit.html', controller: 'AccountEditController' } } }

    sp.state "account.vote", { url: "/account_vote", views: { 'account-vote': { templateUrl: 'account_vote.html', controller: 'AccountVoteController' } } }

    sp.state "account.wall", { url: "/account_wall", views: { 'account-wall': { templateUrl: 'account_wall.html', controller: 'AccountWallController' } } }

    sp.state "blocks",
        url: "/blocks?withtrxs"
        templateUrl: "blocks.html"
        controller: "BlocksController"

    sp.state "createwallet",
        url: prefix + "/createwallet"
        templateUrl: (
            if window.bts
                "brainwallet.html"
            else
                "createwallet.html"
        )
        controller: (
            if window.bts
                "BrainWalletController"
            else
                "CreateWalletController"
        )

    sp.state "block",
        url: prefix + "/blocks/:number"
        templateUrl: "block.html"
        controller: "BlockController"

    sp.state "blocksbyround",
        url: "/blocks/round/:round?withtrxs"
        templateUrl: "blocksbyround.html"
        controller: "BlocksByRoundController"

    sp.state "transaction",
        url: prefix + "/tx/:id"
        templateUrl: "transaction.html"
        controller: "TransactionController"

    sp.state "unlockwallet",
        url: prefix + "/unlockwallet"
        templateUrl: (
            if window.bts
                "brainwallet.html"
            else
                "unlockwallet.html"
        )
        controller: (
            if window.bts
                "BrainWalletController"
            else
                "UnlockWalletController"
        )

    sp.state "brainwallet",
        url: prefix + "/brainwallet"
        templateUrl: "brainwallet.html"
        controller: "BrainWalletController"

    sp.state "transfer",
        url: prefix + "/transfer?from&to&amount&memo&asset"
        templateUrl: "transfer.html"
        controller: "TransferController"

    sp.state "newcontact",
        url: prefix + "/newcontact?name&key"
        templateUrl: "newcontact.html"
        controller: "NewContactController"

    sp.state "advanced",
        url: prefix + "/advanced"
        templateUrl: "advanced/advanced.html"
        controller: "AdvancedController"

    sp.state "notebooks",
        url: prefix + '/notes'
        templateUrl: 'notes/notebooks.html'
        controller: "NotebooksController"

    sp.state "notes",
        url: prefix + '/note/:name'
        templateUrl: 'notes/notes.html'
        controller: "NotesController"

    sp.state "packets",
        url: prefix + '/packets'
        templateUrl: 'packets/packets.html'
        controller:  'PacketsController'