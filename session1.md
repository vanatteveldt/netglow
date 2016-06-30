<style>

.reveal .slides > sectionx {
    top: -70%;
}

.reveal pre code.r {background-color: #ccF}

.section .reveal li {color:white}
.section .reveal em {font-weight: bold; font-style: "none"}

</style>




Analysing Texts and Networks with R
========================================================
author: Wouter van Atteveldt, Nel Ruigrok, Kasper Welbers
date: Session 1: R Intro & Accessing APIs

Motivational Example
========================================================






```r
library(twitteR)
tweets = searchTwitteR("#bigdata", resultType="recent", n = 100)
tweets = plyr::ldply(tweets, as.data.frame)
```


```r
kable(head(tweets[c("id", "created", "text")]))
```



|id                 |created             |text                                                                                                                                         |
|:------------------|:-------------------|:--------------------------------------------------------------------------------------------------------------------------------------------|
|737606276188753921 |2016-05-31 11:26:54 |#BigData : comment s'enrichir en partageant #tribune @LesEchos https://t.co/6kbaQmd40J                                                       |
|737606250024689666 |2016-05-31 11:26:48 |RT @jamesturner247: Is Big Data Taking Us Closer to the Deeper Questions in Artificial Intelligence? https://t.co/Z7ZsI1mzLB #ArtificialInt… |
|737606227358711809 |2016-05-31 11:26:43 |RT @jamesturner247: Big Data and the Cloud: Uncover New #Insights Hiding in Your Data https://t.co/NM9BNukkXX #BigData #DataScience #Health… |
|737606216243761152 |2016-05-31 11:26:40 |momentum in today’s #BigData #data #analytics landscape.
https://t.co/poK5ksaOTO https://t.co/Mmzlf6vJS1                                     |
|737606192755675141 |2016-05-31 11:26:35 |Heather Knight is speaking at #smartcon2016 in Istanbul
Marilyn Monrobot - Kurucu, Robotist #bigdata #IoT #Startup https://t.co/xuHZR6vORY   |
|737606191333793792 |2016-05-31 11:26:34 |RT @Informatica: At @strataconf, learn how to turn #bigdata into big value! https://t.co/T2Jvn3JRqh #StrataHadoop https://t.co/tqneHPVTzk    |

Motivational Example
======


```r
library(RTextTools)
library(corpustools)
dtm = create_matrix(tweets$text)
dtm.wordcloud(dtm, freq.fun = sqrt)
```

![plot of chunk unnamed-chunk-5](session1-figure/unnamed-chunk-5-1.png)


Workshop Overview
===
type:section 

Session 1
+ *Organizing & Transforming data*
+ Accessing APIs from R

Session 2
+ Corpus Analysis
+ Network Analysis

Introduction
===

+ Please introduce yourself
  + What is your research interest
  + What do you want to use R for?
  + Experience with R / text / programming


Course Components
===

+ Two 1.5 hour sessions
+ Lecture & Interactive sessions
  + Please interrupt me!
+ Hands-on sessions
+ http://vanatteveldt.com
  + Slides, hand-outs, data

What is R?
===

+ Programming language
+ Statistics Toolkit
+ Open Source
+ Community driven
  + Packages/libraries
  + Including many text analysis libraries
  
Cathedral and Bazar
===

<img src="cath_bazar.jpg">
  
The R Ecosystem
===

+ R
+ RStudio
  + RMarkdown / RPresentation
+ Packages
  + CRAN
  + Github


Installing and using packages
===


```r
install.packages("plyr")
library(plyr)
plyr::rename

devtools::install_github("amcat/amcat-r")
```

Data types: vectors
===


```r
x = 12
class(x)
```

```
[1] "numeric"
```

```r
x = c(1, 2, 3)
class(x)
```

```
[1] "numeric"
```

```r
x = "a text"
class(x)
```

```
[1] "character"
```

Data Frames
===


```r
df = data.frame(id=1:3, age=c(14, 18, 24), 
          name=c("Mary", "John", "Luke"))
df
```

```
  id age name
1  1  14 Mary
2  2  18 John
3  3  24 Luke
```

```r
class(df)
```

```
[1] "data.frame"
```

Selecting a column
===


```r
df$age
```

```
[1] 14 18 24
```

```r
df[["age"]]
```

```
[1] 14 18 24
```

```r
class(df$age)
```

```
[1] "numeric"
```

```r
class(df$name)
```

```
[1] "factor"
```

Useful functions
===

Data frames:


```r
colnames(df)
head(df)
tail(df)
nrow(df)
ncol(df)
summary(df)
```

Vectors:


```r
mean(df$age)
length(df$age)
```


Other data types
===

+ Data frame:
  + Rectangular data frame
  + Columns vectors of same length
    + (vetor always has one type)
+ List:
  + Contain anything (inc data frames, lists)
  + Elements arbitrary type
+ Matrix:
  + Rectangular
  + All cells same (primitive) type
  
  
Finding help (and packages)
===

+ Ask a friend!
+ Built-in documentation
  + CRAN package vignettes
+ Task views
+ Google (sorry...)

Organizing Data in R
===
type: section
  

Subsetting

Recoding & Renaming columns

Ordering



Subsetting
===


```r
df[1:2, 1:2]
```

```
  id age
1  1  14
2  2  18
```

```r
df[df$id %% 2 == 1, ]
```

```
  id age name
1  1  14 Mary
3  3  24 Luke
```

```r
df[, c("id", "name")]
```

```
  id name
1  1 Mary
2  2 John
3  3 Luke
```

Subsetting: `subset` function
===

```r
subset(df, id == 1)
```

```
  id age name
1  1  14 Mary
```

```r
subset(df, id >1 & age < 20)
```

```
  id age name
2  2  18 John
```

Recoding columns
===
  

```r
df2 = df
df2$age2 = df2$age + df2$id
df2$age[df2$id == 1] = NA
df2$id = NULL
df2$old = df2$age > 20
df2$agecat = 
  ifelse(df2$age > 20, "Old", "Young")
df2
```

```
  age name age2   old agecat
1  NA Mary   15    NA   <NA>
2  18 John   20 FALSE  Young
3  24 Luke   27  TRUE    Old
```

Text columns
===

+ `character` vs `factor`


```r
df2=df
df2$name = as.character(df2$name)
df2$name[df2$id != 1] = 
    paste("Mr.", df2$name[df2$id != 1])
df2$name = toupper(df2$name)
df2$name = gsub("\\.\\s*", "_", df2$name)
df2[grepl("mr", df2$name, ignore.case = T), ]
```

```
  id age    name
2  2  18 MR_JOHN
3  3  24 MR_LUKE
```

Renaming columns
===


```r
df2 = df
colnames(df2) = c("ID", "AGE", "NAME")
colnames(df2)[2] = "leeftijd"
df2 = plyr::rename(df2, c("NAME"="naam"))
df2
```

```
  ID leeftijd naam
1  1       14 Mary
2  2       18 John
3  3       24 Luke
```
  
Ordering
====


```r
df[order(df$age), ]
```

```
  id age name
1  1  14 Mary
2  2  18 John
3  3  24 Luke
```

```r
plyr::arrange(df, -age)
```

```
  id age name
1  3  24 Luke
2  2  18 John
3  1  14 Mary
```

Accessing elements
====

+ Data frame
  + Select one column: `df$col`, ` df[["col"]]`, 
  + Select columns: `df[c("col1" ,"col2")]`
  + Subset: `df[rows, columns]`
+ List:
  + Select one element: `l$el`, ` l[["el"]]`, `l[[1]]` 
  + Select columns: `l[[1:3]]`
+ Matrix:
  + All cells same type
  + Subset: `m[rows, columns]`




Transforming data
====
type:section

Combining data

Reshaping data

Combining data
=====




```r
cbind(df, country=c("nl", "uk", "uk"))
```

```
  id age name country
1  1  14 Mary      nl
2  2  18 John      uk
3  3  24 Luke      uk
```

```r
rbind(df, c(id=1, age=2, name="Mary"))
```

```
  id age name
1  1  14 Mary
2  2  18 John
3  3  24 Luke
4  1   2 Mary
```

Merging data
===


```r
countries = data.frame(id=1:2, country=c("nl", "uk"))
merge(df, countries)
```

```
  id age name country
1  1  14 Mary      nl
2  2  18 John      uk
```

```r
merge(df, countries, all=T)
```

```
  id age name country
1  1  14 Mary      nl
2  2  18 John      uk
3  3  24 Luke    <NA>
```

Merging data
===


```r
merge(data1, data2)
merge(data1, data2, by="id")
merge(data1, data2, by.x="id", by.y="ID")
merge(data1, data2, by="id", all=T)
merge(data1, data2, by="id", all.x=T)
```

Reshaping data
===

+ `reshape2` package:
  + `melt`: wide to long
  + `dcast`: long to wide (pivot table) 

Melting data
===


```r
wide = data.frame(id=1:3, 
  group=c("a","a","b"), 
  width=c(100, 110, 120), 
  height=c(50, 100, 150))
wide
```

```
  id group width height
1  1     a   100     50
2  2     a   110    100
3  3     b   120    150
```

Melting data
===


```r
library(reshape2)
long = melt(wide, id.vars=c("id", "group"))
long
```

```
  id group variable value
1  1     a    width   100
2  2     a    width   110
3  3     b    width   120
4  1     a   height    50
5  2     a   height   100
6  3     b   height   150
```


Casting data
===


```r
dcast(long, id + group ~ variable, value.var="value")
```

```
  id group width height
1  1     a   100     50
2  2     a   110    100
3  3     b   120    150
```

Casting data: aggregation
===


```r
dcast(long, group ~ variable, value.var = "value", fun.aggregate = max)
```

```
  group width height
1     a   110    100
2     b   120    150
```

```r
dcast(long, id ~., value.var = "value", fun.aggregate = mean)
```

```
  id   .
1  1  75
2  2 105
3  3 135
```

Aggregation with `aggregate`
===


```r
aggregate(long["value"], long["group"], max)
```

```
  group value
1     a   110
2     b   150
```

`aggregate` vs `dcast`
===

Aggregate
+ One aggregation function
+ Multiple value columns
+ Groups go in rows (long format)
+ Specify with column subsets

Cast
+ One aggregation function
+ One value column
+ Groups go in rows or columns
+ Specify with formula (`rows ~ columns`)


Simple statistics
===

Vector properties


```r
mean(x)
sd(x)
sum(x)
```

Basic tests


```r
t.test(wide, width ~ group)
t.test(wide$width, wide$height, paired=T)
cor.test(wide$width, wide$height)
m = lm(long, width ~ group + height)
summary(m)
```



Workshop Overview
===
type:section 

Session 1
+ Organizing & Transforming data
+ *Accessing APIs from R*

Session 2
+ Corpus Analysis
+ Network Analysis


What is an API?
===

+ Application Programming Interface
+ Computer-friendly web page
  + Standardized requests
  + Structured response
    + json/ csv
+ Access directly (HTTP call)
+ Client library for popular APIs

    
Package twitteR
===


```r
install_github("geoffjentry/twitteR") 
setup_twitter_oauth(...)
tweets = searchTwitteR("#Trump2016", resultType="recent", n = 10)
tweets = plyr::ldply(tweets, as.data.frame)
```

Package Rfacebook
===


```r
install_github("pablobarbera/Rfacebook", subdir="Rfacebook")
fb_token = fbOAuth(fb_app_id, fb_app_secret)
p = getPage(page="nytimes", token=fb_token)
post = getPost(p$id[1], token=fb_token)
```

Package rtimes
====


```r
install.packages("rtimes")
options(nytimes_as_key = nyt_api_key)

res = as_search(q="trump", 
  begin_date = "20160101", 
  end_date = '20160501')

arts = plyr::ldply(res$data, 
  function(x) c(headline=x$headline$main, 
                date=x$pub_date))
```

APIs and rate limits
===

+ Most APIs have access limits
+ Log on with key or token
+ Response size (page) limited to n results
+ Requests limited to n per hour/day
+ Some clients deal with this, some don't
+ See API and client documentation


Directly accessing APIs
===

+ Make HTTP requests directly from R
  + package `httr` (or `RCurl`)
+ Can access all web data source
+ Need to figure out authentication, structure, etc


Directly accessing APIs
===


```r
domain = 'https://api.nytimes.com'
path = 'svc/search/v2/articlesearch.json'
url = paste(domain, path, url, sep='/')
query = list(`api-key`=key, q="clinton")
r = httr::GET(url, query=query)
status_code(r)
result = content(r)
result$response$docs[[1]]$headline
```

Hands-on 1
===
type:section

Handouts: 
+ Using APIs
+ Collect some data for corpus/network analysis
+ See also: http://vanatteveldt.com/netglow


