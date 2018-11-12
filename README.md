# censusr

[![Build Status](https://travis-ci.org/transportfoundry/censusr.svg?branch=master)](https://travis-ci.org/transportfoundry/censusr)

## Discontinued Development
***We decided to deprecate censusr and instead use (and contribute) to 
[tidycensus](https://github.com/walkerke/tidycensus). Censusr will remain on
CRAN, but support will discontinue.***

## Censusr Description
Access data hosted by the US Census Bureau.

The Census has made a very nice API for data scientists to access their data
tables. The `censusr` package will help R users access this API in a convenient
and R-like way.

The API works by sending a specially-formatted URL to the the Census API server,
which returns an XML or JSON document containing the requested information. In 
practice, any table available on American FactFinder is available through the
API, though the user will need to find the raw name for the variable in the
Census API 
[guide](http://api.census.gov/data/2015/acs5/subject/variables.html).

## Setup
These instructions are modified from hadley's 
[API best practices documentation](https://cran.r-project.org/package=httr/vignettes/api-packages.html).

1. Users of this package will need to request an API key, which is available for 
free from the Census Bureau on request. Go to
[http://api.census.gov/data/key_signup.html](http://api.census.gov/data/key_signup.html)
to register. Copy this token to your clipboard.

2. Identify your home directory. If you are not sure what it is, enter 
`normalizePath("~/")` in an R session. If in RStudio, use the R console.

3. Create a new text file. If in RStudio, do File > New File > Text file.

4. Create a line like this:

```
CENSUS_TOKEN=blahblahblahblahblahblah

```

where the name `CENSUS_TOKEN` reminds you which API this is for and 
`blahblahblahblahblahblah` is your token, pasted from the clipboard. Make sure 
the last line in the file is empty. (If it is not empty, R will silently fail 
to load the file. If you're using an editor that shows line numbers, there 
should be two lines, where the second one is empty.)

5. Save this file in your home directory with the filename `.Renviron`. If 
questioned, YES you do want to use a filename that begins with a dot `.`.

Note that by default dotfiles are usually hidden. But within RStudio, the file 
browser will make `.Renviron` visible and therefore easy to edit in the future.

6. Restart R. `.Renviron` is processed only at the start of an R session.

7. Use `Sys.getenv()` to access your token. For example,


```r
call_census_api(..., api_key = Sys.getenv("CENSUS_TOKEN") ...)
```

FAQ: Why define this environment variable via `.Renviron` instead of in 
`.bash_profile` or `.bashrc`?

Because there are many combinations of OS and ways of running R where the 
`.Renviron` approach "just works"" and the bash stuff does not. When R is a 
child process of, say, Emacs or RStudio, you can't always count on environment 
variables being passed to R. Put them in an R-specific start-up file and save 
yourself some grief.

## Use
The package works by sending a list of requested variables and a list of
geographies. The call below requests the number of households owning 0, 1, 2, 3,
or 4 or more vehicles in Wake County, North Carolina (`geoid = 37183`). We
specify that we want this table for 2012 5-year summary level.


```r
library(censusr)
call_census_api(
  paste("B08201_", sprintf("%03d", 2:6),  "E", sep = ""),
  names = c(0:4), geoids = "37183",  
  data_source = "acs", year =  2012, period = 5) 
```

```
## Source: local data frame [1 x 6]
## 
##   geoid     0      1      2     3     4
##   (chr) (dbl)  (dbl)  (dbl) (dbl) (dbl)
## 1 37183 15813 111992 149742 47222 16534
```

We can use the `allgeos` argument to say that we actually want these variables
for *all* census tracts within Wake County.


```r
est <- call_census_api(
  paste("B08201_", sprintf("%03d", 2:6),  "E", sep = ""),
  names = paste0("est_", c(0:4)), geoids = "37183",  allgeos = "tr",
  data_source = "acs", year =  2012, period = 5) 
est
```

```
## Source: local data frame [187 x 6]
## 
##          geoid est_0 est_1 est_2 est_3 est_4
##          (chr) (dbl) (dbl) (dbl) (dbl) (dbl)
## 1  37183050100   248   516   310    37     0
## 2  37183050300   293   826   489    51    19
## 3  37183050400    44   369   328    23     9
## 4  37183050500   181   885   436    87    30
## 5  37183050600   289   600   209    69    19
## 6  37183050700   503   584   218   118     0
## 7  37183050800   359   227   162    74     0
## 8  37183050900   442   249    80     3     0
## 9  37183051000   202   543   329    68    28
## 10 37183051101   149   201   208    54    64
## ..         ...   ...   ...   ...   ...   ...
```

If we want the margins of error on this table instead of the estimates, we can
change the variable to call the `M` type instead of the `E` type.


```r
moe <- call_census_api(
  paste("B08201_", sprintf("%03d", 2:6),  "M", sep = ""),
  names = paste0("moe_", c(0:4)), geoids = "37183",  allgeos = "tr",
  data_source = "acs", year =  2012, period = 5) 
moe
```

```
## Source: local data frame [187 x 6]
## 
##          geoid moe_0 moe_1 moe_2 moe_3 moe_4
##          (chr) (dbl) (dbl) (dbl) (dbl) (dbl)
## 1  37183050100    87   169    81    52    13
## 2  37183050300   101   163   106    53    22
## 3  37183050400    25    80    62    21    13
## 4  37183050500    75   143    98    54    29
## 5  37183050600    95   112    76    47    14
## 6  37183050700   109    97    82    61    13
## 7  37183050800    94    85    73    58    13
## 8  37183050900    91    78    43     6    13
## 9  37183051000    96   117    99    61    44
## 10 37183051101    78    75    80    83    79
## ..         ...   ...   ...   ...   ...   ...
```
