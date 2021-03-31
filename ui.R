library(shiny)
library(shinydashboard)

ui <- dashboardPage(
  dashboardHeader(title = "Mark Syphus"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Overall Sentiment", tabName = "overall", icon = icon("dashboard")),
      menuItem("Resume", tabName = "resume", icon = icon("th")),
      menuItem("Articles", tabName = "articles", icon = icon("th"))
    )
  ),
  dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
    ),
    tabItems(
      tabItem(tabName = "overall",
              fluidRow(
                box(plotOutput("overallTop10")),
                box(plotOutput("overallCloud"))
              ),
              fluidRow(
                box(plotOutput("overallEmotions"), width = 4),
                box(plotOutput("overallWords"), width = 6),
                valueBoxOutput("overallSentiment", width = 2)
              )
      ),
      tabItem(tabName = "resume",
              fluidRow(
                box(plotOutput("resumeTop10")),
                box(plotOutput("resumeCloud"))
              ),
              fluidRow(
                box(plotOutput("resumeEmotions"), width = 4),
                box(plotOutput("resumeWords"), width = 6),
                valueBoxOutput("resumeSentiment", width = 2)
              )        
      ),
      tabItem(tabName = "articles", 
              fluidRow(
                box(plotOutput("articlesTop10")),
                box(plotOutput("articlesCloud"))
              ),
              fluidRow(
                box(plotOutput("articlesEmotions"), width = 4),
                box(plotOutput("articlesWords"), width = 6),
                valueBoxOutput("articlesSentiment", width = 2)
              )             
      )
    )
  )
)