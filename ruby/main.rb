require "twitter"
require "redis"
require "./twitter_helper"
require "./importer"
require "./exporter"
require "./utils"
require "csv"


redis = Redis.new(:host => "localhost", :port => 6379, :db => "simply-connected")

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = "Sj8FN4ar2raFu7RBKqUqSnY3Q"
  config.consumer_secret     = "DP2IyZSQTnmdHyyKwEQnTlOXokLaOmrcbF6xlkiDBeq5dhgNr7"
  # config.access_token        = ""
  # config.access_token_secret = ""
end


user_id = 15721946 # SimplyBusiness
importer = Importer.new(redis, client)
exporter = Exporter.new(redis, client)


# importer.user(user_id)
# importer.user_timeline(user_id)
#
# importer.user_timeline(user_id).each do |tweet|
#   if (tweet.retweet_count > 0 && not(tweet.text.start_with?("RT")))
#     with_retry do
#       importer.tweet_retweets(tweet.id)
#     end
#   end
# end
# #
# importer.user_places()

# importer.friends(user_id)
# importer.followers(user_id)


to_csv(exporter.all_users(), "../data/users.csv")
to_csv(exporter.all_tweets(), "../data/tweets.csv")
to_csv(exporter.retweets(), "../data/retweets.csv")
to_csv(exporter.all_hash_tags(), "../data/tags.csv")
to_csv(exporter.all_tweet_tags(), "../data/tweet_tags.csv")
to_csv(exporter.locations(), "../data/locations.csv")

# puts exporter.locations()

# to_csv(exporter.user_places(), "user_places.csv")
