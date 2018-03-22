
library(twitteR) #for the rest API
#https://cran.r-project.org/web/packages/twitteR/twitteR.pdf

library(streamR) #for the streaming API
library(ROAuth)
#https://cran.r-project.org/web/packages/streamR/streamR.pdf

library(tidyverse)

#To get your API credentials:

#1. go to https://apps.twitter.com/ and hit the "Create New App" button.

#2. Give your app a name, a description, and a website. For the website, you can use a placeholder such as "http://thisisaplaceholder.com".

#3. When you're done, hit the "Create new Twitter application" button.

#4. Next, go to the "Keys and Access Tokens" tab and hit the Create my access token button at the bottom.

#5. Copy the information from the next page into the four fields below.





access_token <- ""
access_secret <-""
consumer_key <- ""
consumer_secret <- ""

#Why are there four keys?

#The primary use for the Twitter API is for websites that want to integrate with Twitter.
#One set of keys belongs to the website. The other set are generated for each of the site's users.

#We are using the same double-key authentication method, so we are going to use both sets.

setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)
#When it prompts you with the question below, answer 2: No
#    Use a local file to cache OAuth access credentials between R sessions?
#    1: Yes
#    2: No


# get the last 100 tweets with the #rstats tag
rstatstweets <- searchTwitter("#rstats", n=5000) %>%
  twListToDF()

View(rstatstweets)


# get the last 100 tweets from @realdonaldtrump
trumptweets <- userTimeline("realdonaldtrump", n=100) %>%
  twListToDF()

View(trumptweets)


# get information about a twitter user
mytwitterprofile <- lookupUsers("galka_max") %>%
  twListToDF()

View(mytwitterprofile)


# check your usage vs the API rate limits
getCurRateLimitInfo()



# *** STREAMING API ***

# This is the same verification method as above, just a different implementation

oathfunction <- function(consumer_key, consumer_secret, access_token, access_secret){
  my_oauth <- ROAuth::OAuthFactory$new(consumerKey=consumer_key,
                                       consumerSecret=consumer_secret,
                                       oauthKey=access_token,
                                       oauthSecret=access_secret,
                                       needsVerifier=FALSE, handshakeComplete=TRUE,
                                       verifier="1",
                                       requestURL="https://api.twitter.com/oauth/request_token",
                                       authURL="https://api.twitter.com/oauth/authorize",
                                       accessURL="https://api.twitter.com/oauth/access_token",
                                       signMethod="HMAC")
  return(my_oauth)
}

my_oauth <- oathfunction(consumer_key, consumer_secret, access_token, access_secret)

# Set the parameters of your stream
# Keep in mind that many of these parameters do not work together
# For example, the location search cannot be paired with other parameters

file = "d:/mytwitterstream.json"       #The data will be saved to this file as long as the stream is running
track = c("trump")                 #"Search" by keyword(s)
follow = NULL                           #"Search" by Twitter user(s)
loc = NULL #c(-179, -70, 179, 70)             #Geographical bounding box -- (min longitute,min latitude,max longitute,max latitude)
lang = NULL                             #Filter by language
timeout = NULL #1000                          #Maximum time (in miliseconds)
tweets = 100 #1000                      #Maximum tweets (usually, it will be less)


filterStream(file.name = file, 
             track = track,
             follow = follow, 
             locations = loc, 
             language = lang,
             #timeout = timeout, 
             tweets = tweets, 
             oauth = my_oauth,
             verbose = TRUE)


#parse the file containing the tweets
streamedtweets <- parseTweets(file, verbose = FALSE)

#set the proper encoding (UTF8 includes many characters not used in the English language)
streamedtweets$text <- iconv(streamedtweets$text, from = "latin1", to = "ascii", sub = "byte")

#replace line breaks with spaces
streamedtweets$text <- gsub("\n", " ", streamedtweets$text)
                       

View(streamedtweets)

