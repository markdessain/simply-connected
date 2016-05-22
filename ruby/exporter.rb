
class Exporter

  def initialize(redis, client)
    @redis = redis
    @client = client
  end

  def get_user(user_id)
    JSON.parse(@redis["user:#{user_id}"])
  end

  def get_friends(user_id)
    @redis.smembers("user:#{user_id}:friends")
  end

  def get_user_timeline(user_id)
    @redis.smembers("user:#{user_id}:tweets").map do |tweet_id|
      JSON.parse(@redis["tweet:#{tweet_id}"])
    end
  end

  def get_user_hash_tags(user_id)
    results = []
    get_user_timeline(user_id).each do |tweet|
      tweet["entities"]["hashtags"].each do |hash_tag|
        results.push(hash_tag["text"].downcase)
      end
    end
    results
  end

end
