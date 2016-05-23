require "twitter"
require "redis"
require "./twitter_helper"
require "./importer"
require "./exporter"
require "./utils"
require "csv"


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


# importer.user(user_id)
# importer.user_timeline(user_id)
#
# importer.get_user_timeline(user_id).each do |tweet|
#   if (tweet["retweet_count"] > 10 && not(tweet["text"].start_with?("RT")))
#     with_retry do
#       importer.tweet_retweets(tweet["id_str"])
#     end
#   end
# end

# importer.friends(user_id)
# importer.followers(user_id)


# puts exporter.user_hash_tags(user_id).join(" ")
# puts exporter.user_locations(user_id).join(" ")
#
# to_csv(exporter.all_users(), "users.csv")
# to_csv(exporter.all_tweets(), "tweets.csv")
# to_csv(exporter.retweets(), "retweets.csv")
# to_csv(exporter.all_hash_tags(), "tags.csv")
# to_csv(exporter.all_tweet_tags(), "tweet_tags.csv")

to_csv(exporter.user_places(), "user_places.csv")
