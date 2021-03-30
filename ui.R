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
      )
    )
  )
)