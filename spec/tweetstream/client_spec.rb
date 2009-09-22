require File.dirname(__FILE__) + '/../spec_helper'

describe TweetStream::Client do
  it 'should set the username and password from the initializers' do
    @client = TweetStream::Client.new('abc','def')
    @client.username.should == 'abc'
    @client.password.should == 'def'
  end

  describe '#build_uri' do
    before do
      @client = TweetStream::Client.new('abc','def')
    end

    it 'should return a URI' do
      @client.send(:build_uri, '').is_a?(URI).should be_true
    end

    it 'should contain the auth information from the client' do
      @client.send(:build_uri, '').user.should == 'abc'
      @client.send(:build_uri, '').password.should == 'def'
    end

    it 'should have the specified path with the version prefix and a json extension' do
      @client.send(:build_uri, 'awesome').path.should == '/1/awesome.json'
    end

    it 'should add on a query string if such parameters are specified' do
      @client.send(:build_uri, 'awesome', :q => 'abc').query.should == 'q=abc'
    end
  end

  describe '#build_query_parameters' do
    before do
      @client = TweetStream::Client.new('abc','def')
    end
  
    it 'should return a blank string if passed a nil value' do
      @client.send(:build_query_parameters, nil).should == ''
    end

    it 'should return a blank string if passed an empty hash' do
      @client.send(:build_query_parameters, {}).should == ''
    end

    it 'should add a query parameter for a key' do
      @client.send(:build_query_parameters, {:query => 'abc'}).should == '?query=abc'
    end

    it 'should escape characters in the value' do
      @client.send(:build_query_parameters, {:query => 'awesome guy'}).should == '?query=awesome+guy'
    end

    it 'should join multiple pairs together' do
      ['?a=b&c=d','?c=d&a=b'].include?(@client.send(:build_query_parameters, {:a => 'b', :c => 'd'})).should be_true
    end
  end

  describe '#start' do
    before do
      @client = TweetStream::Client.new('abc','def')
    end

    it 'should make a call to Yajl::HttpStream' do
      Yajl::HttpStream.should_receive(:get).once.with(URI.parse('http://abc:def@stream.twitter.com/1/cool.json'), :symbolize_keys => true).and_return({})
      @client.start('cool')
    end

    it 'should yield a TwitterStream::Status for each update' do
      Yajl::HttpStream.should_receive(:get).once.with(URI.parse('http://abc:def@stream.twitter.com/1/statuses/filter.json?track=musicmonday'), :symbolize_keys => true).and_yield(sample_tweets[0])
      @client.track('musicmonday') do |status|
        status.is_a?(TweetStream::Status).should be_true
        @yielded = true
      end
      @yielded.should be_true
    end
  end
  
  describe ' API methods' do
    before do
      @client = TweetStream::Client.new('abc','def')
    end
    
    it '#track should make a call to start with "statuses/filter" and a track query parameter' do
      @client.should_receive(:start).once.with('statuses/filter', :track => 'test')
      @client.track('test')
    end
    
    it '#track should comma-join multiple arguments' do
      @client.should_receive(:start).once.with('statuses/filter', :track => 'foo,bar,baz')
      @client.track('foo', 'bar', 'baz')
    end
    
    it '#follow should make a call to start with "statuses/filter" and a follow query parameter' do
      @client.should_receive(:start).once.with('statuses/filter', :follow => '123')
      @client.follow(123)
    end
    
    it '#follow should comma-join multiple arguments' do
      @client.should_receive(:start).once.with('statuses/filter', :follow => '123,456')
      @client.follow(123, 456)
    end
  end

  describe '#track' do
    before do
      @client = TweetStream::Client.new('abc','def')
    end

    it 'should call #start with "statuses/filter" and the provided queries' do
      @client.should_receive(:start).once.with('statuses/filter', :track => 'rock')
      @client.track('rock')
    end
  end
end
