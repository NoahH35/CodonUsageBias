#!/usr/bin/env Rscript

library(xlsx)
library(ggplot2)
library(ggpubr)

  #change to correct directory for the genome you are working on by adding to the end 
# read in gc1, gc2 and gc3 
gc1 <- read.table("gc1", header = FALSE)
gc2 <- read.table("gc2", header = FALSE)
gc3 <- read.table("gc3", header = FALSE)

#combine
df2 <- cbind(gc1, gc2, gc3)
df <- df2[c(2,4,6)]

#compute mean of column 1 and 2
df$gc12 <- rowMeans(df[ , c(1,2)], na.rm=TRUE)

#create X and Y axis
gc12 = df$gc12
gc3 = df$V2.2

#option 1: do not include Pearson's rho and p-value 
#make png
png("neutralityplot.png", width = 200, height = 200, units = 'mm', res = 300)
ggplot(df, aes(x=gc3, y=gc12)) + geom_hex() + geom_smooth(method=lm, se=FALSE, col='red') + stat_regline_equation(label.y = 0.05, size = 6) +
    theme (axis.text = element_text(size = 15), text = element_text(size = 20)) + xlim(0,1.05) +ylim(0,1.05) +
    ggtitle(" ") + theme(plot.title = element_text(hjust = 0.5)) 
dev.off()

  #change text  sizes: https://statisticsglobe.com/change-font-size-of-ggplot2-plot-in-r-axis-text-main-title-legend
  #geom_hex: hexagonal density plot 
  #ggtitle: plot title 
  #theme: plot title size 
  #xlim and ylim: ranges of x and y


#make plot
#ggplot(df, aes(x=gc3, y=gc12)) + geom_point()

# make densityplot: 
#see: https://r-graph-gallery.com/2d-density-plot-with-ggplot2.html
#ggplot(df, aes(x=gc3, y=gc12)) + geom_hex()

#add trendline and regression line 
#ggplot(df, aes(x=gc3, y=gc12)) + geom_hex() + geom_smooth(method=lm, se=FALSE, col='red')
#red linear trendline, and hide shaded confidence region 
#ggplot(df, aes(x=gc3, y=gc12)) + geom_hex() + geom_smooth(method=lm, se=FALSE, col='red') +
#stat_regline_equation(label.y = 0.05, size = 6) + 
#theme (axis.text = element_text(size = 15), text = element_text(size = 20)) +
#ggtitle("plottitle") + theme(plot.title = element_text(hjust = 0.5)) +xlim(0,1.05) +ylim(0,1.05)


#include Pearson's rho and P-value 
#ggplot(df, aes(x=gc3, y=gc12)) + geom_hex() + geom_smooth(method=lm, se=FALSE, col='red') + stat_cor(label.y = 0.25) + stat_regline_equation(label.y = 0.3)

#include R2 and P-value 

#option 2:
  #write labels for trendline and R2
 # lm_eqn <- function(df){
 # +     m <- lm(gc12 ~ gc3, df);
 # +     eq <- substitute(italic(y) == a + b %.% italic(x)*","~~italic(r)^2~"="~r2, 
 #                        +                      list(a = format(unname(coef(m)[1]), digits = 2),
 #                                                    +                           b = format(unname(coef(m)[2]), digits = 2),
 #                                                    +                           r2 = format(summary(m)$r.squared, digits = 3)))
 # +     as.character(as.expression(eq));
 # + }

  #plot  
#  ggplot(df, aes(x=gc3, y=gc12)) + geom_hex() + geom_smooth(method=lm, se=FALSE, col='red') + geom_text(aes(x = 0.25, y = 0.1, label = lm_eqn(df)), parse = TRUE)

  
  
  #to save plot as png 
#  png("neutralityplot.png", width = 400, height = 400, units = 'mm', res = 300)
#  ggplot(df, aes(x=gc3, y=gc12)) + geom_hex() + geom_smooth(method=lm, se=FALSE, col='red') + geom_text(aes(x = 0.25, y = 0.1, label = lm_eqn(df)), parse = TRUE)
#  dev.off()
