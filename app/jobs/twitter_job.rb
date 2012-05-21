class TwitterJob
  @queue = :tweet

  attr_accessor :user, :authentication

  def self.perform(user, authentication)
    self.new(user, authentication).run
  end

  def initialize(user, authentication)
    @user = User.find(user["id"])
    @authentication = authentication
  end

  def client
    @client ||= Twitter::Client.new({
      :consumer_key => ENV["TWITTER_KEY"],
      :consumer_secret => ENV["TWITTER_SECRET"],
      :oauth_token => authentication["token"],
      :oauth_token_secret => authentication["secret"]})
  end

  def uid
    @uid ||= authentication['uid'].to_i
  end

  def run
    if user.twitter_items.any?
      get_recent_tweets
    else
      get_all_tweets
    end
    user.save
  end

  def get_all_tweets
    client.user_timeline(uid).reverse.each do |tweet| 
      user.twitter_items.create(:tweet => tweet, :tweet_time => tweet.created_at)
    end
  end

  def get_recent_tweets
    client.user_timeline(uid, :since_id => last_tweet_id).reverse.each do |tweet| 
      user.twitter_items.create(:tweet => tweet, :tweet_time => tweet.created_at)
    end
  end

  def last_tweet_id
    user.last_twitter_item.tweet.id
  end
end 