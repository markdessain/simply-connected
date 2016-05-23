
class Importer

  def initialize(redis, client)
    @redis = redis
    @client = client
  end

  def user(user_id)
    @redis["user:#{user_id}"] = @client.user(user_id).to_hash.to_json
  end

  def friends(user_id)
    @client.friends(user_id).each do |friend|
      @redis.sadd("user:#{user_id}:friends", friend.id)
      @redis["user:#{friend.id}"] = friend.to_hash.to_json
    end
  end

  def followers(user_id)
    @client.followers(user_id).each do |follower|
      @redis.sadd("user:#{user_id}:followers", follower.id)
      @redis["user:#{follower.id}"] = follower.to_hash.to_json
    end
  end

  def user_timeline(user_id)
    get_all_tweets(user_id, @client).each do |tweet|
      @redis.sadd("user:#{user_id}:tweets", tweet.id)
      @redis["tweet:#{tweet.id}"] = tweet.to_hash.to_json
    end
  end

  def tweet_retweets(tweet_id)
    get_all_retweets(tweet_id, @client).each do |tweet|
      @redis.sadd("tweet:#{tweet_id}:retweets", tweet.id)
      @redis.sadd("user:#{tweet.user.id}:tweets", tweet.id)
      @redis["tweet:#{tweet.id}"] = tweet.to_hash.to_json
      @redis["user:#{tweet.user.id}"] = tweet.user.to_hash.to_json
    end
  end

end
