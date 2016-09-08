function(input,output){
        library(shiny)
        library(dplyr)
        library(ggplot2)
        library(knitr)
        library(rpart)
        library(rpart.plot)
        #library(rattle)
        library(plotly)
        #library(DT)
        mytable<-readRDS(file='mydata.Rda')
        mytable<-dplyr::select(mytable,c(ticker,sector,mktcap,D_E,pm))
        names(mytable)=c('ticker','sector','mkt_cap','D_E','profit_margin')
        sumbysector<-mytable %>% group_by(sector) %>% summarise (numberofstocks=length(D_E),
                                                                 median_debt_ratio=median(D_E)*100,median_profit_margin=median(profit_margin)*100) %>% arrange(median_debt_ratio)
        p<-plot_ly(mytable, x =D_E , color = sector, type = "box") %>% layout(
                title = "Debt Distribution by Sector",
                xaxis = list(title = "Debt to Equity"))
        p2<-ggplot(mytable,aes(D_E,profit_margin))+geom_point(aes(colour=sector))+facet_wrap(~sector)+
                ggtitle('Profit Margin ~ Debt by Sector')+xlab('Long term Debt')+ylab('Profit margin')
        
        testdb<-runif(100)
        
        plotType<-function(x,type){switch(type,A=hist(x),B=barplot(x))}
        
        objtext<-"- This tool initiates the exploration of the relationship between debt to equity (D/E ) ratios and profit margins of publicly traded companies.
        The analysis is limited to companies that belong to the Standard & Poor's 500 index. These are among the largest companies in North America.
        The initial data was downloaded from www.FinViz.com and only serves to support the assignment.
        Please refer to the accompanying presentation for conclusions in the github repository."
        
        defintext<-" Only companies that are members of the S & P 500 index (500 companies) are covered.
        Companies with incomplete information were excluded, resulting in 397 companies (out of 502 initially)
        We explore the relationship of debt/equity to net margins by sector.
        To normalize the debt of companies the debt to equity ratio is used (D/E) instead of the dollar value of debt
        To avoid outliers, in some of the graphs we have limited company's D/E ratios to 200% or lower.
        
        Definitions:
        - Mkt capitalization: refers to the total dollar market value of the company's outstanding shares ( mktcap)
        - Debt to equity ratio: refers to the relative proportion of shareholders' equity to debt(ltdeb)
        - Net Profit Margin: net proft divided by sales(pm)"
        
        concltext<-"We conclude that debt does not appear to have a significant impact on profit margins of companies."
        textchunk<-function(type){switch(type,Objective=objtext,Definitions=defintext,Conclusions=concltext)}
        
        # Generate summary stats
        output$intros<-renderText({textchunk(input$pType)})
        output$tableview<-renderDataTable({sumbysector},options = list(pageLength = 10))
        # Generate distribution by sector
        output$plot<-renderPlotly({p})
        # Generate debt to profit margin
        output$plot2<-renderPlot({p2})
        # Generate DB table
        output$db<-renderDataTable({mytable},options = list(pageLength = 10))
        output$plot3<-renderPlot({selectedData<-reactive({mytable[,c('D_E',input$sType)]})
        clusters<-reactive(kmeans(selectedData(),input$clusters))
        plot(selectedData(),col=clusters()$cluster,pch=20,cex=3, main='K-Means Clustering')
        points(clusters()$centers,pch=1,cex=4,lwd=4)
        })
}