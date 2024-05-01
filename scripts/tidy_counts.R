dir.create(Sys.getenv("R_LIBS_USER"), recursive = TRUE)  # create personal library
.libPaths(Sys.getenv("R_LIBS_USER"))  # add to the path

install.packages(c("tidyverse", "magrittr","stringr","dplyr"),repos = "http://cran.us.r-project.org")

library(tidyverse)
library(magrittr)
library(stringr)
library(dplyr)

## Load counts.txt file for data tidying
counts <- read.delim("/Volumes/argon_home/Workflow_Liz/Counts/counts.txt", comment.char="#", header= TRUE, row.names = 1)

## Removing ENSEMBL version numbers (e.g., ENG0898O.1 -> ENGENG0898O)
row.names(counts) %<>% str_remove("\\.[0-9]+$")

## Removing Chr, Start, End, Strand, and Length columns for iDEP analysis
counts_tidy <- counts[,-c(1:5)]

## Writing as csv file (raw counts)
write.csv(counts_tidy, file = "/Volumes/argon_home/Workflow_Liz/Counts/counts_tidy.csv")

