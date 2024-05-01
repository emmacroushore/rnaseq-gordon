dir.create(Sys.getenv("R_LIBS_USER"), recursive = TRUE)  # create personal library
.libPaths(Sys.getenv("R_LIBS_USER"))  # add to the path

install.packages(c("tidyverse", "magrittr","stringr","dplyr"),repos = "http://cran.us.r-project.org")

library(tidyverse)
library(magrittr)
library(stringr)
library(dplyr)

## load counts.txt file for data tidying
counts <- read.delim("counts.txt", comment.char="#", header= TRUE, row.names = 1)

## remove ENSEMBL version numbers (e.g., ENG0898O.1 -> ENGENG0898O)
row.names(counts) %<>% str_remove("\\.[0-9]+$")

## remove Chr, Start, End, Strand, and Length columns for easy input into iDEP for analysis
counts_tidy <- counts[,-c(1:5)]

## write to csv file (output to cwd unless otherwise specified)
write.csv(counts_tidy, file = "counts_tidy.csv")

