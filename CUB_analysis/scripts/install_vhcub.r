#!/usr/bin/env Rscript

# install.vhcub
if (!requireNamespace("devtools", quietly=TRUE)){
        install.packages("devtools")}
devtools::install_github('AliYoussef96/vhcub')

# install.hexbin
install.packages("hexbin")