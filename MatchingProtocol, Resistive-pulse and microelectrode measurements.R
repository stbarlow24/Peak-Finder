## This script matches peaks from separate data frames such that signals from
## the nanopore measurement can be successfully paired to those from 
## the electrochemical measurement.

## The script relies on time-series data to accumulate matches.  Reshape2 is used
## to melt nanopore and electrochemical signals together.



subset.collision.data <- collision.data %>%
        group_by(AppliedPressure, TrialNumber) %>%
        arrange(Time) %>%
        mutate(allInterspike = c(0,diff(Time))) %>% 
        na.omit()
      
head(subset.collision.data)


matching.collision.data<- subset.collision.data %>%
        group_by(AppliedPressure, TrialNumber) %>%
        arrange(Time) %>%
        mutate(matches = case_when(MeasurementType == "CF" & 
                                     lag(MeasurementType) == "NP" & 
                                     allInterspike < 1 ~"Match!",
                                   MeasurementType == "NP" & 
                                     lead(MeasurementType) == "CF" & 
                                     lead(allInterspike) < 1 ~"Match!",
                                   MeasurementType == "CF"& 
                                     lag(MeasurementType) == "CF"|
                                     MeasurementType == "NP" &
                                     lag(MeasurementType) == "NP"~ "No Match!"))
matching.collision.data$matches
head(matching.collision.data)

BinarizeMatches<- matching.collision.data %>%
        #na.omit() %>%
        group_by(AppliedPressure, TrialNumber) %>%
        mutate(BinaryMatch = ifelse(matches == "Match!", 1, 0),
               BinaryMeasure = ifelse(MeasurementType == "NP", 1, 0))
head(BinarizeMatches)

print(BinarizeMatches[1:100,14:18])


incrementMatches<- BinarizeMatches %>%
        group_by(AppliedPressure, TrialNumber) %>%
        filter(BinaryMatch != 0) %>%
        mutate(incrementMatches = paste0("Match", cumsum(c(1, diff(BinaryMeasure)==1))))
print(incrementMatches[1:100, 16:20])


##apply a split filter -recombine method
##Start by splitting the dataframes into the NP signals with only the match and the dI
##add it to the dataframe writ large
###First we separate out the CF values

head(incrementMatches)
onlyCF.values<- incrementMatches %>%
      filter(MeasurementType == "CF", NumberMolecules > 600)

drops <- c("SourceMeasurement", "Liposome_Dilution", "matches", "BinaryMatch", "BinaryMeasure","Baseline", "deltaI", "Q") #columns to be dropped (reduce number of observations)
onlyCF.values<- onlyCF.values[ , !(names(onlyCF.values) %in% drops)] #drop column

head(onlyCF.values)

onlyNP.values<- incrementMatches %>%
      filter(MeasurementType == "NP")
colnames(onlyNP.values)[colnames(onlyNP.values)=="Thalf"]<- "Duration"
NPkeeps<- c("TrialNumber", "AppliedPressure", "incrementMatches","deltaI","Duration")
onlyNP.values<- onlyNP.values[NPkeeps]#drop column

correlatedMatches<- left_join(onlyCF.values,onlyNP.values, by = c("incrementMatches","AppliedPressure","TrialNumber"))
correlatedMatches[,6:10]

  
  summariseMatches<- correlatedMatches %>%
        group_by(AppliedPressure) %>%
        #na.omit()%>%
        summarise_at(c("deltaI","Duration","NumberMolecules","Thalf","allInterspike"),MeanSE)
  summariseMatches