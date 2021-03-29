library(shiny)
library(shinydashboard)

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
                box(plotOutput("overallEmotions", height=300)),
                box(plotOutput("overallWords", height=300))
              )
      )
    )
  )
)