library(shiny)
library(shinydashboard)
library(tm)
library(wordcloud)
library(syuzhet)
library(ggplot2)
library(rvest)
library(magrittr)
library(RColorBrewer)
library(tidytext)
library(dplyr)
library(stringr)

### Create text objects

#Resume
resume <- readLines("resume.txt")

#LinkedIn Articles
foodWasteURL <- read_html("https://www.linkedin.com/pulse/what-would-happen-we-stopped-wasting-food-mark-syphus/")
foodWaste <- foodWasteURL %>% html_nodes("p") %>% html_text()
foodWaste <- foodWaste[-c(16:22)]

productURL<-read_html("https://www.linkedin.com/pulse/what-does-your-product-say-mark-syphus/")
product<-productURL %>% html_nodes("p") %>% html_text()
product<-product[-c(12:18)]

successURL <- read_html("https://www.linkedin.com/pulse/greatest-success-mark-syphus/")
success <- successURL %>% html_nodes("p") %>% html_text()
success <- success[-c(7:13)]

fishingURL <- read_html("https://www.linkedin.com/pulse/fishing-best-business-school-mark-syphus-%E8%88%92%E9%A9%AC%E5%85%8B-/")
fishing <- fishingURL %>% html_nodes("p") %>% html_text()
fishing <- fishing[-c(9:15)]

leanURL <- read_html("https://www.linkedin.com/pulse/how-you-killing-your-lean-program-dont-know-mark-syphus-%E8%88%92%E9%A9%AC%E5%85%8B-/")
lean <- leanURL %>% html_nodes("p") %>% html_text()
lean <- lean[-c(9:15)]

# Create Corpus for all files
docs <- VCorpus(VectorSource(c(resume, foodWaste, product, success, fishing, lean)))
res <- VCorpus(VectorSource(resume))
arts <- VCorpus(VectorSource(c(foodWaste, product, success, fishing, lean)))

# Clean up text: remove special characters, convert case, remove numbers, remove stopwords, etc.
specialCharacters<-content_transformer(
  function(x, pattern)
    gsub(pattern, " ", x)
)
docs <- tm_map(docs, specialCharacters, "-")
docs <- tm_map(docs, specialCharacters, "%")
docs <- tm_map(docs, specialCharacters, "&")
docs <- tm_map(docs, specialCharacters, "'")
docs <- tm_map(docs, removeNumbers)
docs <- tm_map(docs, removePunctuation)
docs <- tm_map(docs, content_transformer(tolower))
docs <- tm_map(docs, removeWords, stopwords("english"))
docs <- tm_map(docs, removeWords, c("etc", "also", "even", "just", "one", "re", "ve"))
docs <- tm_map(docs, stripWhitespace)

res <- tm_map(res, specialCharacters, "-")
res <- tm_map(res, specialCharacters, "%")
res <- tm_map(res, specialCharacters, "&")
res <- tm_map(res, specialCharacters, "'")
res <- tm_map(res, removeNumbers)
res <- tm_map(res, removePunctuation)
res <- tm_map(res, content_transformer(tolower))
res <- tm_map(res, removeWords, stopwords("english"))
res <- tm_map(res, removeWords, c("etc", "also", "even", "just", "one", "re", "ve"))
res <- tm_map(res, stripWhitespace)

arts <- tm_map(arts, specialCharacters, "-")
arts <- tm_map(arts, specialCharacters, "%")
arts <- tm_map(arts, specialCharacters, "&")
arts <- tm_map(arts, specialCharacters, "'")
arts <- tm_map(arts, removeNumbers)
arts <- tm_map(arts, removePunctuation)
arts <- tm_map(arts, content_transformer(tolower))
arts <- tm_map(arts, removeWords, stopwords("english"))
arts <- tm_map(arts, removeWords, c("etc", "also", "even", "just", "one", "re", "ve"))
arts <- tm_map(arts, stripWhitespace)


# Create document matrix and data frame
termDocs <- TermDocumentMatrix(docs)
docsMat <- as.matrix(termDocs)
docsMat <- sort(rowSums(docsMat), decreasing = TRUE)
docsDf <- data.frame(word = names(docsMat), freq = docsMat)

termRes <- TermDocumentMatrix(res)
resMat <- as.matrix(termRes)
resMat <- sort(rowSums(resMat), decreasing = TRUE)
resDf <- data.frame(word = names(resMat), freq = resMat)

termArts <- TermDocumentMatrix(arts)
artsMat <- as.matrix(termArts)
artsMat <- sort(rowSums(artsMat), decreasing = TRUE)
artsDf <- data.frame(word = names(artsMat), freq = artsMat)

# Explore results
hist(docsDf$freq)

# Get sentiment data
emo <- get_nrc_sentiment(c(resume, foodWaste, product, success, fishing, lean))
syu <- get_sentiment(c(resume, foodWaste, product, success, fishing, lean), method = "syuzhet")
syuSum <- round(sum(syu), 0)
bing <- get_sentiments("bing")
joined <- inner_join(docsDf, bing, "word")

emoRes <- get_nrc_sentiment(resume)
syuRes <- get_sentiment(resume, method = "syuzhet")
syuSumRes <- round(sum(syuRes))
joinedRes <- inner_join(resDf, bing, "word")

emoArts <- get_nrc_sentiment(c(foodWaste, product, success, fishing, lean))
syuArts <- get_sentiment(c(foodWaste, product, success, fishing, lean), method = "syuzhet")
syuSumArts <- round(sum(syuArts))
joinedArts <- inner_join(artsDf, bing, "word")

server <- function(input, output) {
  output$overallTop10 <- renderPlot({
    barplot(docsDf[1:10,]$freq, las = 2, names.arg = docsDf[1:10,]$word, col = "#7570b3", main = "Top 10 Most Occurring Words", ylab = "Word Occurrences", ylim = c(0, 30))
  })
  output$overallCloud <- renderPlot({
    wordcloud(words = docsDf$word, freq = docsDf$freq, min.freq = 3, scale = c(3.5,0.25), max.words = 100, random.order = FALSE, rot.per = 0.35, colors = brewer.pal(5, "Dark2"))
  })
  output$overallEmotions <- renderPlot({
    emoLabs <- sort(colSums(prop.table(emo)))
    barplot(emoLabs, horiz = TRUE, col = "#7570b3", main = "Overall Emotional Sentiment", xlab = "Frequency of Occurrence(%)", xlim = c(0, 0.30), yaxt = "n")
    text(x = -0.02, y = seq(1, 13, 1.25), labels = names(emoLabs), srt = -45, xpd = TRUE)
  })
  output$overallWords <- renderPlot({
    joined %>% 
      filter(freq > 5) %>%
      mutate(freq = ifelse(sentiment == "negative", -freq, freq)) %>%
      mutate(word = reorder(word, freq)) %>%
      ggplot(aes(word, freq, fill = sentiment)) + geom_col() + scale_fill_manual(values = c("#dd4b39", "#00a65a")) + coord_flip() + labs(y = "Sentiment Score") + scale_y_continuous(breaks = seq(-25, 25, 5))
  })
  output$overallSentiment<-renderValueBox({
      valueBox(syuSum, "Accumulative Sentiment Score", icon = icon("thumbs-up", lib = "glyphicon"), col = "green")
  })
  output$resumeTop10 <- renderPlot({
    barplot(resDf[1:10,]$freq, las = 2, xaxt = "n", col = "#7570b3", main = "Top 10 Most Occurring Words", ylab = "Word Occurrences", ylim = c(0, 13))
    text(x = seq(0.5, 12, 1.2), y = -1.5, labels = resDf[1:10,]$word, srt = 45, xpd = TRUE)
  })
  output$resumeCloud <- renderPlot({
    wordcloud(words = resDf$word, freq = resDf$freq, scale = c(3.5,0.25), max.words = 100, random.order = FALSE, rot.per = 0.35, colors = brewer.pal(5, "Dark2"))
  })
  output$resumeEmotions <- renderPlot({
    emoResLabs <- sort(colSums(prop.table(emoRes)))
    barplot(emoResLabs, horiz = TRUE, col = "#7570b3", main = "Overall Emotional Sentiment", xlab = "Frequency of Occurrence(%)", xlim = c(0, 0.40), yaxt = "n")
    text(x = -0.02, y = seq(1, 13, 1.25), labels = names(emoResLabs), srt = -45, xpd = TRUE)
  })
  output$resumeWords <- renderPlot({
    joinedRes %>% 
      mutate(freq = ifelse(sentiment == "negative", -freq, freq)) %>%
      mutate(word = reorder(word, freq)) %>%
      ggplot(aes(word, freq, fill = sentiment)) + geom_col() + scale_fill_manual(values = c("#dd4b39", "#00a65a")) + coord_flip() + labs(y = "Sentiment Score")
  })
  output$resumeSentiment<-renderValueBox({
    valueBox(syuSumRes, "Accumulative Sentiment Score", icon = icon("thumbs-up", lib = "glyphicon"), col = "green")
  })
  output$articlesTop10 <- renderPlot({
    barplot(artsDf[1:10,]$freq, las = 2, names.arg = artsDf[1:10,]$word, col = "#7570b3", main = "Top 10 Most Occurring Words", ylab = "Word Occurrences", ylim = c(0, 30))
  })
  output$articlesCloud <- renderPlot({
    wordcloud(words = artsDf$word, freq = artsDf$freq, min.freq = 3, scale = c(3.5,0.25), max.words = 100, random.order = FALSE, rot.per = 0.35, colors = brewer.pal(5, "Dark2"))
  })
  output$articlesEmotions <- renderPlot({
    emoArtsLabs <- sort(colSums(prop.table(emoArts)))
    barplot(emoArtsLabs, horiz = TRUE, col = "#7570b3", main = "Overall Emotional Sentiment", xlab = "Frequency of Occurrence(%)", xlim = c(0, 0.30), yaxt = "n")
    text(x = -0.02, y = seq(1, 13, 1.25), labels = names(emoArtsLabs), srt = -45, xpd = TRUE)
  })
  output$articlesWords <- renderPlot({
    joinedArts %>% 
      filter(freq > 5) %>%
      mutate(freq = ifelse(sentiment == "negative", -freq, freq)) %>%
      mutate(word = reorder(word, freq)) %>%
      ggplot(aes(word, freq, fill = sentiment)) + geom_col() + scale_fill_manual(values = c("#dd4b39", "#00a65a")) + coord_flip() + labs(y = "Sentiment Score") + scale_y_continuous(breaks = seq(-25, 15, 5))
  })
  output$articlesSentiment<-renderValueBox({
    valueBox(syuSumArts, "Accumulative Sentiment Score", icon = icon("thumbs-up", lib = "glyphicon"), col = "green")
  })
}

