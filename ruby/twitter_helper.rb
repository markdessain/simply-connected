
def with_retry
  begin
    yield
  rescue Twitter::Error::TooManyRequests => error
    # NOTE: Your process could go to sleep for up to 15 minutes but if you
    # retry any sooner, it will almost certainly fail with the same exception.
    puts error.rate_limit.reset_in
    sleep error.rate_limit.reset_in + 1
    retry
  end
end


def collect_with_max_id(collection=[], max_id=nil, &block)
  response = yield(max_id)
  collection += response
  response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
end

def get_all_tweets(user_id, client)
  collect_with_max_id do |max_id|
    options = {count: 200, include_rts: true}
    options[:max_id] = max_id unless max_id.nil?
    client.user_timeline(user_id, options)
  end
end

def get_all_retweets(tweet_id, client)
  collect_with_max_id do |max_id|
    options = {count: 100, include_rts: true}
    options[:max_id] = max_id unless max_id.nil?
    client.retweets(tweet_id, options)
  end
end
