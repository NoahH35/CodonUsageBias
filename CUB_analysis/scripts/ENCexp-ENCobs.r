#!/usr/bin/env Rscript

# open needed packages 
library(vhcub)
library(xlsx)
library(ggplot2)
library(ggpubr)
library(seqinr)

# import data
df <- read.csv("output.txt", sep = ";")
gc3 <- df[4]
NCobs <- df[3]
# add rownames 
df$names <- rownames(df)


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
ncexp$GC3s <- as.numeric(ncexp$GC3s)
ncexp$GC3s.1 <- as.numeric(ncexp$GC3s.1)
df$Nc <- as.numeric(df$Nc)
df$GC3s <- as.numeric(df$GC3s)


gc3 <- df[4]
NCobs <- df[3]
NCexp <- ncexp[2]
names(NCexp) [1]<- paste("NCexp")
names(NCobs) [1] <- paste("NCobs")
names(gc3) [1] <- paste("GC3")

NCexp$names <- rownames(df)
NCobs$names <- rownames(df)
gc3$names <- rownames(df)

#combine tables and print new table with only ENCexp ENCobs and GC3
total1 <- merge(gc3, NCobs, by="names")
total2 <- merge(total1, NCexp, by="names")


# Ncobs < NCexp 

# percentage of genes where Ncobs < NCexp 
