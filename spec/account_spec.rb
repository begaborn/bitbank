require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Bitbank::Account" do
  before(:each) do
    @client = Bitbank.new(File.join(File.dirname(__FILE__), '..', 'config.yml'))
    @account = Bitbank::Account.new(@client, 'adent', 0.02)
  end

  it 'should have a name' do
    @account.name.should == 'adent'
  end

  describe 'address' do
    use_vcr_cassette 'account/address'

    it 'should retrieve the address for this account' do
      @account.address.should == '1NqwGDRi9Gs4xm1BmPnGeMwgz1CowP6CeQ'
    end
  end

  describe 'balance' do
    use_vcr_cassette 'account/balance'

    it 'should retrieve the current balance' do
      @account.balance.should == 0.02
    end
  end

  describe 'transactions' do
    use_vcr_cassette 'account/transactions'

    it 'should retrieve transactions for this account' do
      transactions = @account.transactions
      transactions.length.should == 1
      transactions.first.is_a?(Bitbank::Transaction).should be_true
      transactions.first.txid.should == 'txid1'
    end
  end
end
