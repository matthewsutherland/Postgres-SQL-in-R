
######## Postgres SQL Queries in R ######## 

# Directory and library set up.
library(RPostgreSQL)
setwd("~/Documents/R_SQL/New_Wave_80s/")

# Import data
album_data <- read.csv("album.csv")
rating_data <- read.csv("ratings.csv")
reviewers_data <- read.csv("reviewers.csv")

# Make DB connection
con <- dbConnect(PostgreSQL(), host="localhost", user= "matthew", 
                 password="---------", dbname="super_cool_application")

# Write data - this code will throw errors of database already exists. 
dbWriteTable(con, "album", album_data)
dbWriteTable(con, "rating", rating_data)
dbWriteTable(con, "reviewers", reviewers_data)

# Query 1
df_query1 <- dbGetQuery(con, "SELECT *
                              From rating
                              WHERE season <> 'Winter'")
# Query 2
df_query2 <- dbGetQuery(con, "SELECT title, year, artist, rating, season
                              FROM album 
                              INNER JOIN rating
                              ON album.album_id = rating.album_id
                              WHERE year < 1988 
                              AND rating <= 6")
# Query 3
df_query3 <- dbGetQuery(con, "SELECT *
                              FROM album 
                              INNER JOIN rating
                              ON album.album_id = rating.album_id 
                              INNER JOIN reviewers
                              ON rating.reviewer_id = reviewers.reviewer_id
                              WHERE album.year > 1984
                              AND reviewers.name <> 'Socrates Soto'
                              ORDER BY album.title") 



