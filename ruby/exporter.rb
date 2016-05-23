require 'set'

class Exporter

  def initialize(redis, client)
    @redis = redis
    @client = client
  end

  def user(user_id)
    JSON.parse(@redis["user:#{user_id}"])
  end

  def tweet(tweet_id)
    JSON.parse(@redis["tweet:#{tweet_id}"])
  end

  def friends(user_id)
    @redis.smembers("user:#{user_id}:friends")
  end

  def user_timeline(user_id)
    @redis.smembers("user:#{user_id}:tweets").map do |tweet_id|
      JSON.parse(@redis["tweet:#{tweet_id}"])
    end
  end

  def user_hash_tags(user_id)
    results = []
    user_timeline(user_id).each do |tweet|
      tweet["entities"]["hashtags"].each do |hash_tag|
        results.push(hash_tag["text"].downcase)
      end
    end

    results
  end

  def user_locations(user_id)
    results = []
    user_timeline(user_id).each do |tweet|
      results.push(tweet["user"]["location"])
    end

    results
  end


  def all_users
    results = []
    @redis.keys("user:*").each do |key|
      if(key.split(":").size == 2)
        user_hash = user(key.split(":")[1])
        results.push({
          "id" => user_hash["id_str"],
          "screen_name" => user_hash["screen_name"],
          "location" => user_hash["location"],
        })
      end
    end

    results
  end

  def all_tweets
    results = []
    @redis.keys("tweet:*").each do |key|
      if(key.split(":").size == 2)
        tweet_hash = tweet(key.split(":")[1])
        results.push({
          "id" => tweet_hash["id_str"],
          "text" => tweet_hash["text"],
          "user_id" => tweet_hash["user"]["id_str"],
        })
      end
    end

    results
  end

  def retweets
    results = []
    @redis.keys("tweet:*:retweets").each do |key|

      original_id = key.split(":")[1]
      @redis.smembers(key).each do |retweet_id|
        results.push({
          "original_id" => original_id,
          "retweet_id" => retweet_id,
        })
      end

    end

    results
  end


  def all_hash_tags
    results = Set.new []
    @redis.keys("tweet:*").each do |key|
      if(key.split(":").size == 2)
        tweet_hash = tweet(key.split(":")[1])

        tweet_hash["entities"]["hashtags"].each do |hash_tag|
          results.add({
            "label" => hash_tag["text"].downcase
          })
        end

      end
    end

    results
  end

  def all_tweet_tags
    results = []
    @redis.keys("tweet:*").each do |key|
      if(key.split(":").size == 2)
        tweet_hash = tweet(key.split(":")[1])

        tweet_hash["entities"]["hashtags"].each do |hash_tag|
          results.push({

            "tweet_id" => tweet_hash["id_str"].downcase,
            "label" => hash_tag["text"].downcase
          })
        end

      end
    end

    results
  end


end
