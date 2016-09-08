# This app support an exploratory analysis of the S & P 500 companies related to debt-profit margin relationships
library(shiny)
library(dplyr)
library(ggplot2)
library(knitr)
library(rpart)
library(rpart.plot)
library(rattle)
library(plotly)
library(DT)

ui<-fluidPage(basicPage(
        h2('Debt and Margins'),
        h5(' Exploration of the relationship between debt and profit margin'),
        flowLayout(selectInput('sel_report','Choose report',choices=c('summary_stats','database_view','distrib_sector'))),
        dataTableOutput('tableview'),
           plotlyOutput('graphview')
))
       
server<-function(input,output){
        mytable<-dplyr::select(mydata,c(ticker,sector,mktcap,ltdeb,pm))
        names(mytable)=c('ticker','sector','mkt_cap','D_E','profit_margin')
        sumbysector<-mytable %>% group_by(sector) %>% summarise (numberofstocks=length(D_E),
                median_debt_ratio=median(D_E)*100,median_profit_margin=median(profit_margin)*100)
        table_rep<-sumbysector %>% arrange(median_debt_ratio)
        p<-plot_ly(mytable, x =D_E , color = sector, type = "box") %>% layout(
                title = "Debt Distribution by Sector",
                xaxis = list(title = "Debt to Equity"))
        p2<-ggplot(mytable,aes(D_E,profit_margin))+geom_point(aes(colour=sector))+facet_wrap(~sector)+
                ggtitle('Profit Margin ~ Debt by Sector')+xlab('Long term Debt')+ylab('Profit margin')
       selection<- reactive({switch(input$sel_report,'summary_stats'=table_rep,'database_view'= mytable)})
       
       output$tableview<-renderDataTable({selection()},options = list(pageLength = 10))
       output$graphview<-renderPlotly({p})
}
shinyApp(ui=ui,server=server)
