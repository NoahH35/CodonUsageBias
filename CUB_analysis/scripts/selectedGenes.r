#!/usr/bin/env Rscript

#install packages
# install.packages("xlsx")
# install.packages("ggplot2")
# install.packages("ggpubr")
# install.packages("seqinr")
# install.packages("dplyr")

# open needed packages 
library(xlsx)
library(ggplot2)
library(ggpubr)
library(seqinr)
library(dplyr)

# import data
df <- read.csv("output.txt", sep = ";")
gc3 <- df[4]
NCobs <- df[3]

#expected functions
f <- function (gc3) 
{
  a=2
  b=20
  c=1
  x=a+gc3+(b/(gc3^2+(c-gc3)^2))
  return(x)
}

ncexp <- data.frame(x=gc3, y=f(gc3))
colnames(ncexp) <- c("gc3", "ncexp")

df$Nc <- as.numeric(df$Nc)
df$GC3s <- as.numeric(df$GC3s)


gc3 <- df[4]
NCobs <- df[3]
NCexp <- ncexp[2]
names(NCexp) [1]<- paste("NCexp")
names(NCobs) [1] <- paste("NCobs")
names(gc3) [1] <- paste("GC3")

rownames(df) <- df$title
NCexp$names <- rownames(df)
NCobs$names <- rownames(df)
gc3$names <- rownames(df)

#combine tables and print new table with only ENCexp ENCobs and GC3
total1 <- merge(gc3, NCobs, by="names")
total2 <- merge(total1, NCexp, by="names")

total2$NCobs <- as.numeric(total2$NCobs) 


# percentage of genes where Ncobs lower NCexp 
# total3 <- total2 %>%  mutate(exp = 0.9 *NCexp) #if you want to use 10% cutoff 
 total3 <- total2 %>% mutate(obs1 = NCobs-NCexp)
data2 <- as.data.frame(total3)
newdata <- total3[ which(total3$obs1 < 0), ]


sink("GenesUnderSelection.txt")
newdata
sink()

