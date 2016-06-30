  
library(twitteR)
library(RTextTools)
library(corpustools)
load("~/learningr/api_auth.rda")
setup_twitter_oauth(tw_consumer_key, tw_consumer_secret, tw_token, tw_token_secret)

tweets.to.dtm = function(tweets) {
  text = gsub("https://.*?( |$)", " ", tweets$text)
  # get rid of all punctuation *except* tags and ats
  text = gsub("[^A-Za-z0-9#@_]+", " ", text)
  m = create_matrix(text, removePunctuation = F)
  rownames(m) = tweets$id
  m
}



leavetags = c("#brexit", "#no2eu", "#notoeu", "#betteroffout", "#voteout", "#eureform", "#britainout", "#leaveeu", "#voteleave", "#beleave", "#loveeuropeleaveeu", "#leaveeu")
remaintags = c("#yes2eu", "#yestoeu", "#betteroffin", "#votein", "#ukineu", "#bremain", "#strongerin", "#leadnotleave", "#voteremain")
q = paste(c(leavetags, remaintags), collapse = " OR ")

hash_tweets_before = searchTwitteR(q, n=2000, lang = "en", since="2016-06-15", until="2016-06-22")
hash_tweets_after = searchTwitteR(q, n=2000, lang = "en", since="2016-06-23", until="2016-06-25")

# get rid of hyperlinks
mptweets_after = searchTwitter("list:Tweetminster/UKMPs", n=2000, since="2016-06-23", until="2016-06-25")
mptweets_before = searchTwitter("list:Tweetminster/UKMPs", n=2000, until="2016-06-22", since="2016-06-15")

save(hash_tweets_before, hash_tweets_after, mptweets_before, mptweets_after, file="tweets.rda")

mptweets_after = plyr::ldply(mptweets_after, as.data.frame)
mptweets_before = plyr::ldply(mptweets_before, as.data.frame)
hash_tweets_after = plyr::ldply(hash_tweets_after, as.data.frame)
hash_tweets_before = plyr::ldply(hash_tweets_before, as.data.frame)

dtm = tweets.to.dtm(c(mptweets_before, mptweets_after))

dtm.tags = dtm[, grepl("#", colnames(dtm))]
dtm.wordcloud(dtm.tags, freq.fun = sqrt)

cmp = corpora.compare(dtm.tags, select.rows = rownames(dtm.tags)[1:2000])
cmp = arrange(cmp, -over)
head(cmp, 100)

with(arrange(cmp, -chi)[1:100, ],
     plotWords(x=log(over), words = term, wordfreq = chi, random.y = T))

stats = arrange(term.statistics(dtm.tags), -termfreq)
head(stats, 20)

dtm.ats = dtm[, grepl("@", colnames(dtm))]
dtm.wordcloud(dtm.ats)
stats = arrange(term.statistics(dtm.ats), -termfreq)
head(stats, 20)

library(igraph)
library(semnet)

dtm.ats = dtm.ats[row_sums(dtm.ats) > 0, ]
triples = dtm.to.df(dtm.ats)
triples$doc = as.numeric(as.character(triples$doc))
mptweets = plyr::ldply(mptweets, as.data.frame)
triples$sender = tolower(mptweets$screenName[triples$doc])
triples$addressee = gsub("@", "", triples$term)

edges = aggregate(cbind(weight=triples$freq), triples[c("sender", "addressee")], sum)
edges = edges[edges$weight >= 2,]
g = igraph::graph.data.frame(edges)
plot(g)

edges[edges$addressee == "jk_rowling",]

g = getBackboneNetwork(g, alpha=0.01, max.vertices=100)
V(g)$cluster = edge.betweenness.community(g)$membership
g = setNetworkAttributes(g, size_attribute=V(g)$freq, cluster_attribute=V(g)$cluster)

plot(g)
