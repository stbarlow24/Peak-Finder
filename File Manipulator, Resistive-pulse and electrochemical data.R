##Goal: Full Analysis of Pressure Data
##Includes: Correlation of NP events with E-Chem Events, % Correlation, overall freqeuency of each, Nmolecules as a fucntion of pressure, compare Nmolecules distributions ktest

##First, pull in files

library(plyr) ###File manipulation
library(dplyr) ###File manipulation
library(ggplot2) ###plotting
library(gridExtra) ###Tabulating data
library(zoo)  ###not used in this, but mathematical functions
library(ggthemes) ###other ggplot2 graph themes
library(DescTools) ###Calculate Area under curve (AUC)
library(tidyr)
library(reshape2)
library(stringr)
library(readr)
library(ggpubr)
library(purrr)

setwd("C:\\Users\\stbar\\Desktop\\Liposome Project, but this time with Au-CFEs\\data matrices\\2019.10.13 Re analyze Pressure depend")
filenames<- list.files(pattern="nanojet", full.names=TRUE)


read_csv_filename <- function(filename){
  ret <- read.csv(filename)
  colnames(ret)[1]<- "Time"
  ret$Source <- filename #EDIT
  ret$Interspike<- c(0, diff(ret$Time))   ### calculates delta_t, parameter to estimate the spike density
  ret$NumberMolecules<- (ret$Q/1/0.096485)*600 ### it's FeCN64-, not dopamine, so only 1 e transfer
  ret$deltaI<-abs(ret$Imax*1000/ret$Baseline*100)
  ret
}

collision.data<- ldply(filenames, read_csv_filename)

##Extract identifiers

collision.data$SourceMeasurement<-str_extract(collision.data$Source, pattern= "\\w\\w\\d\\d") ##adds layer with electrodeID (differentiate trials from one another) 
collision.data$Liposome_Dilution<-str_extract(collision.data$Source, pattern= "\\d\\d\\d\\dx")
collision.data$TrialNumber<-str_extract(collision.data$Source, pattern= "t\\d")
collision.data$MeasurementType<- str_extract(collision.data$Source, pattern = "NP|CF") 
collision.data$AppliedPressure<- str_extract(collision.data$Source, pattern = "\\d\\dpsi")
drops <- c("Source") #columns to be dropped (reduce number of observations)
collision.data<- collision.data[ , !(names(collision.data) %in% drops)] #drop column
head(collision.data)


