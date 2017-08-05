# Postgres-SQL-in-R
### Introduction
This tutorial explains how to query a Postgres SQL database in R. To do this the package `RPostgreSQL` is used, along with 3 sample relations that concern the rating of new wave 80’s albums. The 3 relations are held in 3 separate .csv files. 

Before beginning please ensure that Postgres SQL has been installed locally, and that a database is available to hold the 3 relations. If you do not yet have Postgres SQL installed, see this tutorial [here](https://www.codementor.io/devops/tutorial/getting-started-postgresql-server-mac-osx). Then make sure that the `RPostgreSQL` package has been installed in R using the `install.package(“”)` command.

You begin by loading the `RPostgreSQL` package. Then you set the working directory to where you will store the .csv files and R script. 

```
library(RPostgreSQL)
setwd("~/Documents/R_SQL/New_Wave_80s/") # Adjust your directory accordingly.
```

After that you can run the following code to import the 3 relations. Below the code block are the 3 relations and their constituent variable definitions. 

```
album_data <- read.csv("album.csv")
rating_data <- read.csv("ratings.csv")
reviewers_data <- read.csv("reviewers.csv")
```

#### Album
- **album_id**: unique identifier for each album rated.
- **title**: title of the album.
- **year**: year the album was released.
- **artist**: artist of the album.

#### Rating
- **reviewer_id**: unique identifier for each reviewer that gave a rating.
- **album_id**: unique identifier for each album rated.
- **rating**: value ranging from 1-10, with 1 being the least favorable rating and 10 being the most favorable.
- **season**: season when the reviewer gave the rating.

#### Reviewers
- **reviewer_id**: unique identifier for each reviewer that gave a rating.
- **name**: first and last name of the reviewer.

### Database Connection

Now you are going to connect to the database. To do so you will need 4 pieces of information:

1. The name of the server hosting the database.
2. Your username for the database.
3. Your password for using the database. 
4. The name of the database. 

Note that I will be storing our 3 relations—`album_data`, `rating_data` and `reviewers_data` onto a local Postgres SQL database (my own computer), rather than on an external server. If you were to use an external server the `host` field  would contain the URL address of the server hosting the database. To open up a connection to the server you use `dbConnect` and enter the host, user, password and database name.

```
con <- dbConnect(PostgreSQL(), host="localhost", user= "matthew", 
                 password="---------", dbname="super_cool_application")
```
Now that the connection is open, you can insert the 3 relations into the database using `dbWriteTable`. 

```
dbWriteTable(con, "album", album_data)
dbWriteTable(con, "rating", rating_data)
dbWriteTable(con, "reviewers", reviewers_data)
```

The relations are now in the database, permitting us to conduct queries. You use `dbGetQuery` to do this. The first parameter you enter is the database connection, followed by the SQL query in quotes. You then save the result into a data frame. 

### SQL

#### Query 1
Produce a data frame that contains all of the album ratings, except for those rated in the Winter. 

```
df_query1 <- dbGetQuery(con, "SELECT *
                              From rating
                              WHERE season <> 'Winter'")
```

#### Query 2
Produce a data frame that contains all of the albums produced before 1988 that had a rating of 6 or lower. But the resulting relation should only contain the title of the album, the year it was released, the artist, the album’s rating and the season in which it was rated. 

```
df_query2 <- dbGetQuery(con, "SELECT title, year, artist, rating, season
                              FROM album 
                              INNER JOIN rating
                              ON album.album_id = rating.album_id
                              WHERE year < 1988 
                              AND rating <= 6")
```

#### Query 3
Produce a data frame that contains all of the albums produced after 1984 with at least a rating of 6, and that was not rated by Socrates Soto. Finally, order the resulting relation by album title. 

```
df_query3 <- dbGetQuery(con, "SELECT *
                              FROM album 
                              INNER JOIN rating
                              ON album.album_id = rating.album_id 
                              INNER JOIN reviewers
                              ON rating.reviewer_id = reviewers.reviewer_id
                              WHERE album.year > 1984
                              AND reviewers.name <> 'Socrates Soto'
                              ORDER BY album.title") 
```

### Summary
Here we see how straight forward it can be to save data into a Postgres SQL database, and how easy it is to query that data using Postgres SQL commands within `dbGetQuery` from the `RPostgreSQL` package. At this point you are ready to begin analysis! In the next tutorial we will learn how to update existing databases, allowing new observations to be added into an existing relation.



