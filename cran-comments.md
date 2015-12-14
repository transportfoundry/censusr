## Test environments
* local OS X install, R 3.2.3
* AWS Ubuntu 14.04.2, LTS R version 3.2.1  
* win-builder (release)

## R CMD check results
There were no ERRORs or WARNINGs.

There was 1 NOTE:

* checking re-building of vignette outputs ... NOTE
  Error in re-building vignettes:
    ...
  Quitting from lines 80-85 (censusr.Rmd) 
  Error: processing vignette 'censusr.Rmd' failed with diagnostics:
  censusr requires an API key. Request one at http://api.census.gov/data/key_signup.html
  Execution halted
  
  
  Explanation - The user needs to obtain their own API key from the US Census
  Bureau to use censusr. The vignette and function documentation contain
  instructions on how to obtain the key and use it, but this prevents us from
  running examples in environments that we do not maintain.
  
## Downstream Dependencies
This is a new package with no dependencies on CRAN.


