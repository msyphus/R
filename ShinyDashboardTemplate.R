library(shiny)
library(shinydashboard)

ui<-dashboardPage(
	dashboardHeader(title="My Dash", 
		dropdownMenu(type = "messages", 
			messageItem(from = "Sales Dept", message = "Sales are up this month."),
			messageItem(from = "New User", message = "How do I register?", icon = icon("question"), time = "13:45"),
			messageItem(from = "Support", message = "The new server is ready.", icon = icon("life-ring"), time = "today")
		),
		dropdownMenu(type = "notifications", 
			notificationItem(text = "2 new users today", icon("users")),
			notificationItem(text = "18 deliveries today", icon("truck")),
			notificationItem(text = "Server load at 93%", icon("exclamation-triangle"), status = "warning")
		),
		dropdownMenu(type = "tasks", badgeStatus = "success", 
			taskItem(value = 90, color = "green", "Documentation"),
			taskItem(value = 12, color = "blue", "Project X"),
			taskItem(value = 77, color = "yellow", "Server Upgrade")
		)
	),
	dashboardSidebar(
		sidebarMenu(
			menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
			menuItem("Widgets", tabName = "widgets", icon = icon("th"), badgeLabel = "New", badgeColor = "green"),
			menuItem("Link", icon = icon("file-code-o"), href = "https://msyphus.github.io")
		)
	),
	dashboardBody(
		tabItems(
			tabItem(tabName = "dashboard", 
				fluidRow(
					box(
						title="Controls",
						sliderInput("slider", "Number of Observations", 1, 100, 50)
					)
				),
				fluidRow(
				box(plotOutput("plot1", height=250)),
				)
			),
			tabItem(tabName = "widgets",
				h2("The Widgets are here!")
			)
		)
	)
)

server<-function(input, output) {
	set.seed(122)
	histdata<-rnorm(500)

	output$plot1<-renderPlot({
	data<-histdata[seq_len(input$slider)]
	hist(data)
	})
}

shinyApp(ui, server)