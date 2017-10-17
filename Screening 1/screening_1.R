setwd("C:/Users/Anthony Caravaggi/Google Drive/Science/Wildlife control meta-analysis/Data")

library(dplyr)

# Read csvs from data folder
temp <-  list.files(pattern="*.csv")
for (i in 1:length(temp)) assign(temp[i], read.csv(temp[i]))

# Extract relevant columns to new dataframes
gs.dat <- select(GoogleScholar.csv, Authors, Title, Year, Source, DOI)
s.dat <- select(Scopus.csv, Authors, Title, Year, Source.title, DOI)
colnames(s.dat)[4] <- "Source"
wos.dat <- select(WebOfScience.csv, Authors, Title, Year, Journal)
colnames(wos.dat)[4] <- "Source"

# Remove original dataframes
rm(list=ls(pattern = "*.csv"))

# Join all dataframes, convert titles to lowercase and remove duplicates
a.dat <- rbind(gs.dat[,1:4], s.dat[,1:4], wos.dat)
a.dat$Title <- tolower(a.dat$Title)
a.dat2 <- a.dat[!duplicated(a.dat$Title),]

# Add column for pairwise grouping of reviewers
set.seed(42)
a.dat2$grp <- sample(c("AAl", "ADa", "ATo", "AlDa", "AlTo", "DaTo"),
       size = nrow(a.dat2), replace = TRUE)

# Split dataframe and save each to a csv
a.spl <- split(a.dat2 , f = a.dat2$grp )

for (i in seq_along(a.spl)) {
  filename = paste(names(a.spl)[i], ".csv")
  write.csv(a.spl[[i]], filename)
}
