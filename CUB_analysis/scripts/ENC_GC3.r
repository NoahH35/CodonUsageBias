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
enc <- df[3]

#expected functions
f <- function (gc3) 
{
    a=2
    b=20
    c=1
    x=a+gc3+(b/(gc3^2+(c-gc3)^2))
    return(x)
}

ncexp <- data.frame(x=seq(0,1,0.01), y=f(seq(0,1,0.01)))
ncexp$x <- as.numeric(ncexp$x)
ncexp$y <- as.numeric(ncexp$y)
df$Nc <- as.numeric(df$Nc)
df$GC3s <- as.numeric(df$GC3s)

# add rownames 
df$names <- rownames(df)

#make png
png("ENC.GC3.png", width = 200, height = 200, units = 'mm', res = 300)
ggplot() + 
  geom_point(data=df, aes(GC3s, Nc), color='blue' ) + 
  geom_line(data=ncexp, aes(x, y), color='red') +
  xlim(0,1) + ylim(0,65)
dev.off()
