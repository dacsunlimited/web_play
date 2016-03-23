# Warning: this is a generated file, any changes made here will be overwritten by the build process

class GameAPI

  constructor: (@q, @log, @rpc) ->
    #@log.info "---- Network API Constructor ----"


  # Exchange lto for chips
  # parameters: 
  #   account_name `from_account_name` - the account that will provide funds for the bid
  #   string `quantity` - the quantity of items you would like to buy
  #   asset_symbol `quantity_symbol` - the type of chips you would like to buy
  # return_type: `transaction_record`
  buy_chips: (from_account_name, quantity, quantity_symbol, error_handler = null) ->
    @rpc.request('game_buy_chips', [from_account_name, quantity, quantity_symbol], error_handler).then (response) ->
      response.result

  # Creates a new game and binding to an asset
  # parameters: 
  #   string `game_name` - the name of the game
  #   string `owner_name` - the name of the owner of the game
  #   string `script_url` - the url of the rule script for this game
  #   string `script_hash` - the hash of the rule script
  #   string `description` - a description of the asset
  #   json_variant `public_data` - arbitrary data attached to the asset
  # return_type: `transaction_record`
  create: (game_name, owner_name, script_url, script_hash, description, public_data, error_handler = null) ->
    @rpc.request('game_create', [game_name, owner_name, script_url, script_hash, description, public_data], error_handler).then (response) ->
      response.result

  # Update a exist game
  # parameters: 
  #   string `paying_account` - the name of the paying account
  #   string `game_name` - the name of the game
  #   string `script_url` - the url of the rule script for this game
  #   string `script_hash` - the hash of the rule script
  #   string `description` - a description of the asset
  #   json_variant `public_data` - arbitrary data attached to the asset
  # return_type: `transaction_record`
  update: (paying_account, game_name, script_url, script_hash, description, public_data, error_handler = null) ->
    @rpc.request('game_update', [paying_account, game_name, script_url, script_hash, description, public_data], error_handler).then (response) ->
      response.result

  # Play game with param variant
  # parameters: 
  #   string `game_name` - the name of the game
  #   json_variant `param` - the param of the game action
  # return_type: `transaction_record`
  play: (game_name, param, error_handler = null) ->
    @rpc.request('game_play', [game_name, param], error_handler).then (response) ->
      response.result

  # Returns stored game datas starting with a given game name upto a the limit provided
  # parameters: 
  #   account_name `game_name` - the game name to include
  #   uint32_t `limit` - the maximum number of items to list
  # return_type: `game_data_record_array`
  list_datas: (game_name, limit, error_handler = null) ->
    @rpc.request('game_list_datas', [game_name, limit], error_handler).then (response) ->
      response.result

  # Returns the status of a particular game, including any trading errors.
  # parameters: 
  #   account_name `game_name` - the game name to include
  # return_type: `game_status`
  status: (game_name, error_handler = null) ->
    @rpc.request('game_status', [game_name], error_handler).then (response) ->
      response.result

  # Returns a list of active game statuses
  # parameters: 
  # return_type: `game_status_array`
  list_status: (error_handler = null) ->
    @rpc.request('game_list_status', error_handler).then (response) ->
      response.result

  # Returns a list of game result transactions executed on a given block.
  # parameters: 
  #   uint32_t `block_number` - Block to get game result transaction operations for.
  # return_type: `game_result_transaction_array`
  list_result_transactions: (block_number, error_handler = null) ->
    @rpc.request('game_list_result_transactions', [block_number], error_handler).then (response) ->
      response.result



angular.module("app").service("GameAPI", ["$q", "$log", "RpcService", GameAPI])
