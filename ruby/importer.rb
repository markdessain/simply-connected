
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
      puts tweet.id
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

  def location_mapping(location, hash)
    @redis["location:#{URI.escape(location).tr(":", "")}"] = hash.to_json
  end

  def user_places
    @redis.keys("user:*").each do |key|
      if(key.split(":").size == 2)
        user_hash = JSON.parse(@redis["user:#{key.split(":")[1]}"])

        begin

          if(user_hash["location"] != "")
            x = Geocoder.search(user_hash["location"])
            sleep 0.3

            if(x != nil)
              puts x[0].class
              if(x[0].class == NilClass)
                raise ""
              end

              location_mapping(
                user_hash["location"],
                {
                  "location" => user_hash["location"],
                  "city" => x[0].city,
                  "state" => x[0].state,
                  "state_code" => x[0].state_code,
                  "sub_state" => x[0].sub_state,
                  "sub_state_code" => x[0].sub_state_code,
                  "country" => x[0].country,
                  "country_code" => x[0].country_code,
                }
              )
            end
          end

        rescue
          puts user_hash["location"]
          sleep 1
        end
      end
    end

  end


end
