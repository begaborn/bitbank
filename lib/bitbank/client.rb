module Bitbank
  class Client
    def initialize(config={})
      @config = config
      @endpoint = "http://#{config[:username]}:#{config[:password]}" +
                  "@#{config[:host]}:#{config[:port]}"
    end

    # Retrieve a particular named account.
    def account(account_name)
      Bitbank::Account.new(self, account_name, nil, true)
    end

    # Rerieve the account that the given Bitcoin address belongs to.
    # Returns nil if the account
    def account_by_address(address)
      account_name = request('getaccount', address)
      if account_name.present?
        account(account_name)
      else
        nil
      end
    end

    # Returns a list of local accounts.
    def accounts
      account_data = request('listaccounts')
      account_data.map do |account_name, account_value|
        Account.new(self, account_name, account_value, false)
      end
    end

    # If an account is not specified, returns the server's total available
    # balance.
    #
    # If an account is specified, returns the balance in the account.
    def balance(account_name=nil)
      request('getbalance', account_name)
    end

    # Returns the number of blocks in the longest block chain.
    def block_count
      request('getblockcount')
    end

    # Returns the block number of the latest block in the longest block chain.
    def block_number
      request('getblocknumber')
    end

    # Returns the number of connections to other nodes.
    def connection_count
      request('getconnectioncount')
    end

    # Returns the proof-of-work difficulty as a multiple of the minimum
    # difficulty.
    def difficulty
      request('getdifficulty')
    end

    # If data is not specified, returns formatted hash data to work on.
    #
    # If data is specified, bitcoind will try to solve the block and will
    # return true or false indicating whether or not it was successful.
    def get_work(data=nil)
      request('getwork', data)
    end

    # Returns a hash containing bitcoind status information.
    def info
      request('getinfo')
    end

    # Returns a new bitcoin account for receiving payments (along with a new
    # address).
    def new_account(name)
      account(name)
    end

    # Returns a new bitcoin address for receiving payments.
    #
    # If an account is specified (recommended), the new address is added to the
    # address book so payments received with the address are credited to the
    # account.
    def new_address(account_name=nil)
      request('getnewaddress', account_name)
    end

    # Returns the most recent transactions for the specified account.
    def transactions(account_name=nil, count=10)
      transaction_data = request('listtransactions', account_name, count)
      transaction_data.map do |txdata|
        Transaction.new(self, txdata['txid'], txdata)
      end
    end

    # Determine if the given address is valid.
    def validate_address(address, locals_invalid=false)
      status = request('validateaddress', address)

      if locals_invalid && status['ismine']
        warn "WARNING: Bitcoin address '#{address}' belongs to local account '#{status['account']}'."
        return false
      end

      status['isvalid']
    end

    def request(method, *args)
      body = { 'id' => 'jsonrpc', 'method' => method }
      body['params'] = args unless args.empty? || args.first.nil?

      response_json = RestClient.post(@endpoint, body.to_json)
      response = JSON.parse(response_json)
      response['result']
    end
  end
end
