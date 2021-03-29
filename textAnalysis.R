library(shiny)
library(shinydashboard)
library(tm)
library(wordcloud)
library(syuzhet)
library(ggplot2)
library(rvest)
library(magrittr)
library(RColorBrewer)

### Create text objects

#Resume
resume<-readLines("resume.txt")

#LinkedIn Articles
foodWasteURL<-read_html("https://www.linkedin.com/pulse/what-would-happen-we-stopped-wasting-food-mark-syphus/")
foodWaste<-foodWasteURL %>% html_nodes("p") %>% html_text()
foodWaste<-foodWaste[-c(16:22)]

productURL<-read_html("https://www.linkedin.com/pulse/what-does-your-product-say-mark-syphus/")
product<-productURL %>% html_nodes("p") %>% html_text()
product<-product[-c(12:18)]

successURL<-read_html("https://www.linkedin.com/pulse/greatest-success-mark-syphus/")
success<-successURL %>% html_nodes("p") %>% html_text()
success<-success[-c(7:13)]

fishingURL<-read_html("https://www.linkedin.com/pulse/fishing-best-business-school-mark-syphus-%E8%88%92%E9%A9%AC%E5%85%8B-/")
fishing<-fishingURL %>% html_nodes("p") %>% html_text()
fishing<-fishing[-c(9:15)]

leanURL<-read_html("https://www.linkedin.com/pulse/how-you-killing-your-lean-program-dont-know-mark-syphus-%E8%88%92%E9%A9%AC%E5%85%8B-/")
lean<-leanURL %>% html_nodes("p") %>% html_text()
lean<-lean[-c(9:15)]

# Create Corpus for all files
docs<-VCorpus(VectorSource(c(resume, foodWaste, product, success, fishing, lean)))

# Clean up text: remove special characters, convert case, remove numbers, remove stopwords, etc.
specialCharacters<-content_transformer(
	function(x, pattern)
		gsub(pattern, " ", x)
	)
docs<-tm_map(docs, specialCharacters, c("-", "%", "&"))
docs<-tm_map(docs, removeNumbers)
docs<-tm_map(docs, removePunctuation)
docs<-tm_map(docs, content_transformer(tolower))
docs<-tm_map(docs, removeWords, stopwords("english"))
docs<-tm_map(docs, stripWhitespace)

# Create document matrix and data frame
termDocs<-TermDocumentMatrix(docs)
docsMat<-as.matrix(termDocs)
docsMat<-sort(rowSums(docsMat), decreasing=TRUE)
docsDf<-data.frame(word=names(docsMat), freq=docsMat)

# Explore results
hist(docsDf$freq)

# Get sentiment data
emo<-get_nrc_sentiment(c(resume, foodWaste, product, success, fishing, lean))

# Create Dashboard

ui<-dashboardPage(
	dashboardHeader(title = "Mark Syphus"),
	dashboardSidebar(
		sidebarMenu(
			menuItem("Overall Sentiment", tabName="overall", icon=icon("dashboard")),
			menuItem("Resume", tabName="resume", icon=icon("th")),
			menuItem("Articles", tabName="articles", icon=icon("th"))
		)
	),
	dashboardBody(
		tabItems(
			tabItem(tabName="overall",
				fluidRow(
					box(plotOutput("overallTop10", height=300)),
					box(plotOutput("overallCloud", height=300))
				),
				fluidRow(
					box(plotOutput("overallEmotions", height=300)) 
				)
			)
		)
	)
)

server<-function(input, output) {
	output$overallTop10<-renderPlot({
		barplot(docsDf[1:10,]$freq, las=2, names.arg=docsDf[1:10,]$word, col="blue", main="Top 10 Most Occurring Words", ylab="Word Occurrences")
	})
	output$overallCloud<-renderPlot({
		wordcloud(words=docsDf$word, freq=docsDf$freq, min.freq=5, max.words=100, random.order=FALSE, rot.per=0.3, colors=brewer.pal(5, "Dark2"))
	})
	output$overallEmotions<-renderPlot({
		barplot(sort(colSums(prop.table(emo))), horiz=TRUE, cex.names=0.6, las=1, main="Overall Emotional Sentiment", xlab="Frequency of Occurrence(%)")
	})
}

shinyApp(ui, server)