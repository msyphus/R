library(shiny)
library(shinydashboard)
library(tm)
library(wordcloud)
library(syuzhet)
library(ggplot2)
library(rvest)
library(magrittr)

resume<-readLines("resume.txt")

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

