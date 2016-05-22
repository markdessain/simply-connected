require "twitter"
require "redis"
require "./twitter_helper"
require "./importer"
require "./exporter"


redis = Redis.new(:host => "localhost", :port => 6379, :db => "simply-connected")

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ""
  config.consumer_secret     = ""
  config.access_token        = ""
  config.access_token_secret = ""
end


user_id = 15721946 # SimplyBusiness
importer = Importer.new(redis, client)
exporter = Exporter.new(redis, client)

# importer.store_user(user_id)
# importer.store_user_timeline(user_id)
#
# importer.get_user_timeline(user_id).each do |tweet|
#   if (tweet["retweet_count"] > 10 && not(tweet["text"].start_with?("RT")))
#     with_retry do
#       importer.store_tweet_retweets(tweet["id_str"])
#     end
#   end
# end

# importer.store_friends(user_id)
# importer.store_followers(user_id)


puts exporter.get_user_hash_tags(user_id).join(" ")
