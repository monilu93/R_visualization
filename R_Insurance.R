#R and ggplot2 for mapping
#By: Monica Perez

install.packages("rmarkdown")



#Dataset from: https://www.kaggle.com/hhs/health-insurance/data

install.packages('ggplot2') #install a package
library(ggplot2) #call the library to use the package

#setting working directory
setwd("")

insurance = read.csv(file.choose()) #if you don't know your working directory or have any other problems
insurance = read.csv("")

View(insurance)
summary(insurance)

#to change the column names to something easier to understand
colnames(insurance) = c("state", "uninsuredRate2010", "uninsuredRate2015", "uninsuredRateChange2010_2015",
                      "healthInsuranceCoverageChange2010_2015", "employerHealthInsuranceCoverage2015",
                      "marketplaceHealthInsuranceCoverage2016", "marketplaceTaxCredits2016",
                      "averageMonthlyTaxCredit2016", "stateMedicaidExpansion2016", "medicaidEnrollment2013",
                      "medicaidEnrollment2016", "medicaidEnrollmentChange2013_2016", "medicareEnrollment2016")

#check data types and change if needed

insurance$averageMonthlyTaxCredit2016 = as.character(insurance$averageMonthlyTaxCredit2016)
insurance$averageMonthlyTaxCredit2016 = gsub(" ", "", insurance$averageMonthlyTaxCredit2016)
insurance$averageMonthlyTaxCredit2016 = gsub("^.", "", insurance$averageMonthlyTaxCredit2016)
insurance$averageMonthlyTaxCredit2016 = as.integer(insurance$averageMonthlyTaxCredit2016)

#create a new variable to know our numbers by region

insurance$regions = NA
insurance$state = as.character(insurance$state)
insurance$state = gsub(" $", "", insurance$state)

#to populate the regions column

for (i in 1:nrow(insurance)){
  if (insurance$state[i] %in% c("Connecticut", "Maine", "Massachusetts", "New Hampshire", "Rhode Island",
                               "Vermont", "New Jersey", "New York", "Pennsylvania")){
    insurance$regions[i] = "Northeast"
  } else if (insurance$state[i] %in% c("Illinois", "Indiana", "Michigan", "Ohio", "Wisconsin",
                                       "Iowa", "Kansas", "Minnesota", "Missouri", "Nebraska",
                                       "North Dakota", "South Dakota")){
    insurance$regions[i] = "Midwest"
  } else if (insurance$state[i] %in% c("Delaware", "Florida", "Georgia", "Maryland", "North Carolina",
                                       "South Carolina", "Virginia", "District of Columbia", "West Virginia",
                                       "Alabama", "Kentucky", "Mississippi", "Tennessee", "Arkansas",
                                       "Louisiana", "Oklahoma", "Texas")){
    insurance$regions[i] = "South"
  } else if (insurance$state[i] %in% c("Arizona", "Colorado", "Idaho", "Montana", "Nevada", "California",
                                       "New Mexico", "Utah", "Wyoming", "Alaska", "Hawaii", "Oregon",
                                       "Washington")){
    insurance$regions[i] = "West"
  } else {
    insurance$regions[i] = NA
  }
}

#to see how many enrolled per region
install.packages('dplyr')
install.packages('sqldf')

library(dplyr)
library(sqldf)

insuranceTotals2016 = insurance %>%
              group_by(regions) %>%
              summarize(totalMedicare2016 = sum(medicareEnrollment2016), totalMedicaid2016 = sum(medicaidEnrollment2016))
             
insuranceTotals2016 = na.omit(insuranceTotals2016)


insuranceTotals2016_sqldf = sqldf('SELECT regions, SUM(medicareEnrollment2016) AS totalMedicare2016,
                                  SUM(medicaidEnrollment2016) AS totalMedicaid2016
                                  FROM insurance 
                                  GROUP BY regions')

insuranceTotals2016_sqldf = na.omit(insuranceTotals2016_sqldf)
                                 

#insuranceTotals2016 and insuranceTotals2016_sqldf are identical, just two different methods

library(ggplot2)

#to plot our findings

#Medicare bar chart
g <- ggplot(insuranceTotals2016, aes(reorder(regions,-totalMedicare2016), totalMedicare2016), fill = totalMedicare2016)+
     geom_bar(position = "dodge", stat = "identity", fill = 'forest green') + 
     scale_y_continuous(labels =  scales::comma) + #coord_flip() +
     ggtitle("Medicare Enrollment 2016 by Region")+
     theme(plot.title = element_text(family = 'serif' ,color="black", size=22, face="italic", hjust = 0.5))+
     theme(axis.title.x = element_blank())+
     theme(axis.title.y = element_blank())+
     theme(axis.text.x= element_text(family = 'serif' ,color="black", size=14))+
     theme(axis.text.y= element_text(family = 'serif' ,color="black", size=14))

#Medicaid bar chart
h <- ggplot(insuranceTotals2016, aes(reorder(regions,-totalMedicaid2016), totalMedicaid2016), fill = totalMedicaid2016)+
      geom_bar(position = "dodge", stat = "identity", fill = 'navy blue') + 
      scale_y_continuous(labels =  scales::comma) + #coord_flip() +
      ggtitle("Medicaid Enrollment 2016 by Region")+
      theme(plot.title = element_text(family = 'serif' ,color="black", size=22, face="italic", hjust = 0.5))+
      theme(axis.title.x = element_blank())+
      theme(axis.title.y = element_blank())+
      theme(axis.text.x= element_text(family = 'serif' ,color="black", size=14))+
      theme(axis.text.y= element_text(family = 'serif' ,color="black", size=14))

#geom_bar() if you want the heights of the bars to represent values in the data, use stat="identity"
#geom_bar() by default x's occurring in the same place with be stacked on top of each other, if you 
#           want them to be dodged from side to side, use position = "dodge"
#theme() is all formatting techniques
#scale_y_continuous() is to not have scientific notation values

install.packages('reshape2')
library(reshape2)

insuranceTotals2016_melt <- melt(insuranceTotals2016)
names(insuranceTotals2016_melt)[3] <- "totalEnrollment"
names(insuranceTotals2016_melt)[2] <- "insurance"

#side by side bar

j = ggplot(insuranceTotals2016_melt, aes(regions, y= totalEnrollment, fill = insurance)) +
      geom_bar(stat="identity", position = "dodge")+
      scale_y_continuous(labels =  scales::comma)+
      ggtitle("Medicare and Medicaid Enrollment 2016 by Region")+
      theme(plot.title = element_text(family = 'serif' ,color="black", size=22, face="italic", hjust = 0.5))+
      theme(axis.title.x = element_blank())+
      theme(axis.title.y = element_blank())+
      theme(axis.text.x= element_text(family = 'serif' ,color="black", size=14))+
      theme(axis.text.y= element_text(family = 'serif' ,color="black", size=14))+
      theme(legend.text = element_text(family = 'serif' ,color="black", size=14))+
      theme(legend.title = element_text(family = 'serif' ,color="black", size=14))+
      scale_fill_manual(values = c("#BE143C", "#3C8A2E")) #to use the MVP colors

#stacked bar

l = ggplot(insuranceTotals2016_melt, aes(regions, y= totalEnrollment, fill = insurance)) +
      geom_bar(stat="identity", position = "stack")+
      scale_y_continuous(labels =  scales::comma)+
      ggtitle("Medicare and Medicaid Enrollment 2016 by Region")+
      theme(plot.title = element_text(family = 'serif' ,color="black", size=22, face="italic", hjust = 0.5))+
      theme(axis.title.x = element_blank())+
      theme(axis.title.y = element_blank())+
      theme(axis.text.x= element_text(family = 'serif' ,color="black", size=14))+
      theme(axis.text.y= element_text(family = 'serif' ,color="black", size=14))+
      theme(legend.text = element_text(family = 'serif' ,color="black", size=14))+
      theme(legend.title = element_text(family = 'serif' ,color="black", size=14))+
      scale_fill_manual(values = c("#BE143C", "#3C8A2E"))


#mapping the data

library(ggmap)

install.packages('maps')
library(maps)

install.packages('mapdata')
library(mapdata)

usa <- map_data("usa")

ggplot() + geom_polygon(data = usa, aes(x=long, y = lat, group = group)) + 
  coord_fixed(1.3)

states <- map_data("state")

ggplot(data = states) + 
  geom_polygon(aes(x = long, y = lat, fill = region, group = group), color = "white") + 
  coord_fixed(1.3) +
  guides(fill=FALSE)  # do this to leave off the color legend

#choosing the data to map

colnames(states) <- c("long", "lat", "group", "order", "state", "subregion")

medicare = insurance[, c(1, 14)]
medicare$state = tolower(medicare$state)

states = states[, c(5, 1, 2, 3, 4, 6)]

medicareStates = inner_join(medicare, states, by = "state")

for (i in 1:nrow(medicareStates)){
  if (i < nrow(medicareStates)){
    if (medicareStates$state[i] == medicareStates$state[i+1]){
      medicareStates$medicareEnrollment2016[i] <- medicareStates$medicareEnrollment2016[i]
      medicareStates$medicareEnrollment2016[i+1] <- 0
    }
  } 
}

#mapping it

states_base <- ggplot(data = medicareStates, mapping = aes(x = long, y = lat, group = group)) + 
  coord_fixed(1.3) + 
  geom_polygon(color = "black", fill = "gray")

remove_the_axes <- theme(
                  axis.text = element_blank(),
                  axis.line = element_blank(),
                  axis.ticks = element_blank(),
                  panel.border = element_blank(),
                  panel.grid = element_blank(),
                  axis.title = element_blank())

gradient_map <- states_base + 
  geom_polygon(data = medicareStates, aes(fill = medicareEnrollment2016), color = "white") +
  geom_polygon(color = "black", fill = NA) +
  theme_bw() +
  remove_the_axes


finalMap = gradient_map + 
  scale_fill_gradientn(colours= c("lightblue", "navyblue"), labels = scales::comma,
                                name = "Population Density")+
  ggtitle("Medicare Population 2016 in the US")+
  theme(legend.title = element_text(family = 'serif' ,color="black", size=14))+
  theme(plot.title = element_text(family = 'serif' ,color="black", size=22, face="italic", hjust = 0.5))
     
  
           
                                    









