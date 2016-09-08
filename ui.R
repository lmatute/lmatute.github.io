fluidPage(theme= "bootstrap.css",
          
          # Introduction of terminlogy 
          titlePanel("Exploring the effect of Debt to Equity ratios on Profit Margings for the S&P 500"),
          
          mainPanel(
                  tabsetPanel(
                          tabPanel('Background Information',list(bootstrapPage(radioButtons('pType','Select:',list('Objective','Definitions','Conclusions')),textOutput('intros')))),
                          tabPanel("Summary table", dataTableOutput("tableview")), 
                          tabPanel("Distribution by Sector", plotlyOutput("plot")), 
                          tabPanel("Debt to profit margin", plotOutput("plot2")), 
                          tabPanel("Database", dataTableOutput("db")),
                          tabPanel("K-means",list(bootstrapPage(numericInput('clusters','Cluster count',5,min=1,max=8),radioButtons('sType','Select:',list("profit_margin","mkt_cap")),plotOutput('plot3'))))
                          
                  )
          )
)