setwd("C:/Users/Anthony Caravaggi/Google Drive/Science/Wildlife control meta-analysis/Data")

library(dplyr)
library(purrr)
library(readr)

# Primary literature
# Read csv names from data folder
wd.p <- "./Primary literature"
file.names <- dir(wd.p, pattern =".csv")

# Loop through names and load files
for(i in file.names){
  filepath <- file.path(wd.p, paste(i,sep=""))
  assign(i, read.csv(filepath, sep = ",", header = TRUE))
}


# Extract relevant columns to new dataframes
gs.dat <- select(GoogleScholar.csv, Authors, Title, Year, Source, DOI)
s.dat <- select(Scopus.csv, Authors, Title, Year, Source.title, DOI)
colnames(s.dat)[4] <- "Source"
wos.dat <- select(WebOfScience.csv, Authors, Title, Year, Journal)
colnames(wos.dat)[4] <- "Source"

# Remove original dataframes
rm(list=ls(pattern = "*.csv"))

# Join all dataframes, convert titles to lowercase and remove duplicates
primary.lit <- rbind(gs.dat[,1:4], s.dat[,1:4], wos.dat)
primary.lit$Title <- tolower(primary.lit$Title)
primary.lit <- primary.lit[!duplicated(primary.lit$Title),]

# Add column for pairwise grouping of reviewers
set.seed(42)
primary.lit$grp <- sample(c("A_An_primary", "A_D_primary", "A_T_primary", "An_D_primary", "An_T_primary", "D_T_primary"),
       size = nrow(primary.lit), replace = TRUE)

# Split dataframe and save each to a csv
primary.lit <- split(primary.lit, f = primary.lit$grp )

for (i in seq_along(primary.lit)) {
  filename = paste(names(primary.lit)[i], ".csv")
  write.csv(primary.lit[[i]], filename)
}

# Grey literature
# List files and read to one dataframe
grey.lit <-
  list.files(path = "./Grey literature/",
             pattern="*.csv", 
             full.names = T) %>% 
  map_df(~read_csv(., col_types = cols(.default = "c"))) 

grey.lit$X3 <- NULL
grey.lit$X4 <- NULL

# Join all dataframes, convert titles to lowercase and remove duplicates
grey.lit$`Anchor Text` <- tolower(grey.lit$`Anchor Text`)
grey.lit <- grey.lit[!duplicated(grey.lit$`Anchor Text`),]

# Add column for pairwise grouping of reviewers
set.seed(42)
grey.lit$grp <- sample(c("A_An_grey", "A_D_grey", "A_T_grey", "An_D_grey", "An_T_grey", "D_T_grey"),
                     size = nrow(grey.lit), replace = TRUE)

# Split dataframe and save each to a csv
grey.lit<- split(grey.lit , f = grey.lit$grp)

for (i in seq_along(grey.lit)) {
  filename = paste(names(grey.lit)[i], ".csv")
  write.csv(grey.lit[[i]], filename)
}
