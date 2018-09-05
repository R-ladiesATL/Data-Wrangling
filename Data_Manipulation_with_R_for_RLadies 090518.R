#Data Manipulation with R
#For R-Ladies
#Date: Sept 5, 2018
#Presenter: Rob Stilson
#Email: robstilson@gmail.com


############################################################################################
############################################################################################
# Clear workspace 
rm(list = ls())

# Setting strings as factors to false
stringsAsFactors = FALSE
############################################################################################

#######################################################################################################
#######################################################################################################
##################################LOADING PACKAGES#####################################################

################################################################################
#Do tryCatch here

tryCatch(require(pacman),finally=utils:::install.packages(pkgs='pacman',repos='http://cran.r-project.org'));
require(pacman)

##if the above doesn't work, use this code##
##tryCatch
#detach("package:pacman", unload = TRUE)
#install.packages("pacman", dependencies = TRUE)
# ## install.packages("pacman")
pacman::p_load(tidyr, dplyr, data.table, xlsx, psych)

#Loading libraries
library(tidyr)
library(dplyr)
library(data.table)
library(xlsx)
library(psych)

detach("package:Hmisc", unload=TRUE)
detach("package:plyr", unload=TRUE)
detach("package:tm", unload=TRUE)
detach("package:cowplot", unload=TRUE)
detach("package:randomForest", unload=TRUE) #must unload this due to conflict with margin in ggplot2 #From: https://github.com/tidyverse/ggplot2/issues/2150


######################################################################################################################
######################################################################################################################
##################################OVERVIEW############################################################################
#Adapted from:
#Jose Portilla
#Data Science and Machine Learning Bootcamp with R
#Section 14: Data Manipulation with R


#dplyr() #manipulating data
#tidyr() #cleaning data

#%>% #pipe operator. Pronounce as "then"

#install.packages("dplyr", dependencies = T)

library(dplyr)

#Notice the warning. It is telling you that `dplyr` is masking those functions from those other packages. Remember if you now need to use 'filter' from the 'stats' package, you will either have to detach 'dplyr' or use the :: as in stats::filter to use it

# Attaching package: 'dplyr'
# 
# The following objects are masked from 'package:stats':
#     
#     filter, lag
# 
# The following objects are masked from 'package:base':
#     
#     intersect, setdiff, setequal, union

#We'll use mtcars, one of the built in data sets for R
View(mtcars)

head(mtcars)

#Let's do a summary
summary(mtcars)

#And structure
str(mtcars)

#And column names
colnames(mtcars)

#And glimpse
glimpse(mtcars)

#And finally describe it
library(psych)
describe(mtcars)

######################################################################################################################
######################################################################################################################
##################################DPLYR VERBS#########################################################################
#Note: we will be using the head() function extensively for these exercises
#This DF isn't very large but it helps when you have one that is


# filter() #select a subset of rows in a DF
# slice() #returns rows by position
# arrange() #reorder rows
# select() #grab certain columns
# rename()
# distinct() #find unique values
# mutate() #create a new variable
# transmute() #create a new variable and only use it
# summarise() #can also use summarize
# sample_n()
# sample_frac()
# group_by()
# ungroup()
# top_n() #Take the top (ex. 5) of your DF

#filter
head(filter(mtcars, cyl == 6, gear == 4))

#Adding in the pipe | for "or"
head(filter(mtcars, (cyl == 6 | cyl == 8), (gear == 4 | gear == 3)))

#Assign to a dataframe
TEST <- mtcars %>%
    filter((cyl == 6 | cyl == 8), (gear == 4 | gear == 3))

#Take a look
View(TEST)

TEST <- mtcars %>%
    filter((mpg >= 20 & cyl <= 8), carb == 4)

#What would this look like in base R?
head(mtcars[mtcars$mpg >= 20 & mtcars$cyl <= 8 & mtcars$carb == 4,])

#Which do you prefer...

#slice
#If we want first 10 rows
slice(mtcars, 1:10)


slice(mtcars, 30:32)

#arrange
head(arrange(mtcars, mpg, cyl, disp, hp))

#What about descending order?
head(arrange(mtcars, desc(mpg), cyl, disp, hp))

#select
#Allows easy subsetting

head(select(mtcars, mpg))

#Two columns?
head(select(mtcars, mpg, cyl))

#A bunch of columns?
#If they are sequential
colnames(mtcars)
head(select(mtcars,cyl:wt))

#If they are not sequential, individually

head(select(mtcars, 
            mpg,
            disp,
            drat,
            qsec,
            am,
            carb
            ))
#I list it out in a "column" form because it is easier for me to see and modify if necessary


#Remove a column?
head(select(mtcars, -mpg))

#Remove a column?
TEST_no_mpg <- head(select(mtcars, -mpg))

#Remove multiple columns?
head(select(mtcars, -c(mpg, carb, vs)))

#Move a column to the front

head(select(mtcars, wt, everything()))

#For more extensive column moving, check out the moveme() function
#From: https://stackoverflow.com/questions/3369959/moving-columns-within-a-data-frame-without-retyping

#Helper variables like everything() within select()!?!?! Tell me more!!!!

# Helpers	Description
# starts_with()	Starts with a prefix
# ends_with()	Ends with a prefix
# contains()	Contains a literal string
# matches()	Matches a regular expression
# num_range()	Numerical range like x01, x02, x03.
# one_of()	Variables in character vector.
# everything()	All variables.

#starts_with()
head(select(mtcars, starts_with("D")))

#contains()
head(select(mtcars, contains("ar")))

#Can we do Regular Expressions? Yup!!!
head(select(mtcars, matches("cyl|dr|mp"))) #Notice the "Or". Pause for Oohs and Aahs...

#rename

head(rename(mtcars, weight = wt)) #notice the sequence is new_name = old_name


#distinct
distinct(select(mtcars, cyl))

#mutate

head(mutate(mtcars, new_col = hp/wt))

#transmute 
#if you only want the new columns back

head(transmute(mtcars, new_col = hp/wt))

#summarise
#with mean()

summarise(mtcars, avg_mpg = mean(mpg, na.rm = TRUE))

#with sum()

summarise(mtcars, total_wt = sum(wt, na.rm = TRUE))


#Sampling
#sample_n
#Give it a number
#set.seed(1)
sample_n(mtcars, 10)

#sample_frac
#Give it a fraction
sample_frac(mtcars, 0.1)

######################################################################################################################
######################################################################################################################
##################################THE PIPE (%>%) OPERATOR#############################################################

library(dplyr)

df <- mtcars #assign mtcars to a DF

#Nesting
result <- arrange(sample_n(filter(df, mpg > 20), size = 5), desc(mpg)) #must read from the inside out. Can get confusing

print(result)

#Multiple Assignments

a <- filter(df, mpg > 20)

b <- sample_n(a, size=5)

result <- arrange(b, desc(mpg))

print(result) #Cleaner to read, but gets messy with all the different assignments

# Pipe Operator
# Data %>% op1 %>% op2 %>% op3 #chained together

result <- df %>% filter(mpg > 20) %>% #Don't need to pass in name of DF since we are chaining
    sample_n(size = 5) %>%
    arrange(desc(mpg))

print(result) #Cleaner to read and much easier to debug

######################################################################################################################
######################################################################################################################
##################################GUIDE TO USING TIDYR################################################################

#install.packages('tidyr')
#install.packages('data.table')

library(tidyr)
library(data.table)

# gather()
# spread()
# seperate()
# unite()

#Note: I pretty much use reshape2 extensively as it can also handle matrices and arrays and I just find the syntax easier to follow. Try them both out and see what works better for you.

# Create a DF

comp <- c(1,1,1,2,2,2,3,3,3)
yr <- c(1998,1999,2000,1998,1999,2000,1998,1999,2000)
q1 <- runif(9, min=0, max=100)
q2 <- runif(9, min=0, max=100)
q3 <- runif(9, min=0, max=100)
q4 <- runif(9, min=0, max=100)

df <- data.frame(comp=comp,year=yr,Qtr1 = q1,Qtr2 = q2,Qtr3 = q3,Qtr4 = q4)

df

#gather()
#Current df is wide (e.g. each quarter is a column)
#Want to rearrange so they are all in one column

df_gather <- gather(df, Quarter, Revenue, Qtr1:Qtr4)

#Format is gather(data, key = "key", value = "value", now put in your columns)
library(reshape2)
#melt()
df_melt <- melt(as.data.frame(df), id.vars = c('comp', 'year'), na.rm = T)


#gather()

stocks <- data.frame(
    time = as.Date('2009-01-01') + 0:9,
    X = rnorm(10, 0, 1),
    Y = rnorm(10, 0, 2),
    Z = rnorm(10, 0, 4)
)
stocks

stocks_gathered <- stocks %>% gather(stock, price, X:Z)

#melt()
stocks_melt <- melt(as.data.frame(stocks), id.vars = c("time"), na.rm = T) #notice your new columns are named "variable" and "value"

#We could have renamed the like so
#From: https://stackoverflow.com/questions/31395209/how-to-name-each-variable-using-melt

stocks_melt2 <- melt(as.data.frame(stocks), id.vars = c("time"), value.name = "price", variable.name = c("stock"), na.rm = T)#However I rarely do this because having the Variable column always called "variable" and the Value column always called "value" makes it much easier to port code and set up automation.

#Now we will spread

#spread()

stocks_spread <- stocks_gathered %>%
    spread(stock, price)

#dcast()

stocks_cast <- dcast(stocks_melt, time ~ variable)

#Could also spread() like this
stocks_spread2 <- stocks_gathered %>%
    spread(time, price) 

stocks_cast2 <- dcast(stocks_melt, variable ~ time)

#separate() 
#Turn a single column into multiple columns

df <- data.frame(new_col = c(NA, "a.x", "b.y", "c.z"))
df

separate(data = df, new_col, into = c("ABC", "XYZ"))

#Let's change separator

df <- data.frame(new_col = c(NA, "a-x", "b-y", "c-z"))
df

separate(data = df, new_col, into = c("ABC", "XYZ"), sep = '-')

#Let's assign this

df_sep <- separate(data = df, new_col, into = c("ABC", "XYZ"), sep = '-')

#Now let's put them together!

#unite()

unite(df_sep, new_joined_col, ABC, XYZ)

# new_joined_col
# 1          NA_NA
# 2            a_x
# 3            b_y
# 4            c_z

#By default it uses an underscore, but we can specify

unite(df_sep, new_joined_col, ABC, XYZ, sep = "---")
# new_joined_col
# 1        NA---NA
# 2          a---x
# 3          b---y
# 4          c---z

#Writing to Excel
#From: http://www.sthda.com/english/wiki/r-xlsx-package-a-quick-start-guide-to-manipulate-excel-files-in-r

library(xlsx)

write.xlsx(stocks_melt, "Y:\\Research and Development\\Rob S Archive\\R Stuff\\R Classes for LM\\My_stocks_data.xlsx", row.names = FALSE, col.names = TRUE, append = FALSE, sheetName = "Melted")

#Lets write another one
write.xlsx(stocks_cast, "Y:\\Research and Development\\Rob S Archive\\R Stuff\\R Classes for LM\\My_stocks_data.xlsx", row.names = FALSE, col.names = TRUE, append = TRUE, sheetName = "Cast")

#For more information on what else you can do with write.xlsx, type ?write.xlsx in your console.