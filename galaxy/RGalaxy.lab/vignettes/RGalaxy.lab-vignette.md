<!--
%\VignetteEngine{knitr::knitr}
%\VignetteIndexEntry{RGalaxy - BioC2013 Lab}
-->

# RGalaxy lab
## July 19, 2013


[Galaxy](http://galaxyproject.org/)
is an open, web-based platform for data-intensive biomedical research.
It provides an easy-to-use web interface and can expose bioinformatics
workflows written in any programming language.

The `RGalaxy` package allows you to take existing `R` functions and
expose them in Galaxy, so that anyone with a web browser can run
your function without needing any knowledge of `R`.

Let's start with a very simple example, based closely on one
from the `RGalaxy` vignette. This is a function which multiplies
two numbers. It's obviously too trivial to be of use to anyone,
but it illustrates some important principles.



```r
multiplyTwoNumbers <- function(number1 = GalaxyNumericParam(required = TRUE), 
    number2 = GalaxyNumericParam(required = TRUE), product = GalaxyOutput("product", 
        "txt")) {
    cat(number1 * number2, file = product)
}
```


There are a few things to notice about this function:

* The data type of each parameter is specified. And instead of 
  just specifying `R`'s `numeric` type, we are using a special
  class called `GalaxyNumericParam`. This is because Galaxy
  (unlike `R`) needs to know the type of each parameter,
  as well as other information
* The function's name is descriptive.
* The return value of the function is not important. 
  Instead, the function writes information to one or more
  files.
* All the function's inputs and outputs are specified as
  named arguments in its signature. This is required as Galaxy
  communicates with tools by sending them files and reading
  files they generate.
* By default, parameters are marked as not required by Galaxy.
  Adding `required=TRUE` tells Galaxy not to allow empty values.
* This function can be run from within R, passing it ordinary
`numeric` values:


```r
t <- tempfile()
multiplyTwoNumbers(2, 7, t)
readLines(t, warn = FALSE)
```

```
## [1] "14"
```


## Documenting the Example

We're almost ready to tell Galaxy about our function, but first we
need to document it with a manual page. `RGalaxy` will use information
in this page to create the Galaxy tool, and the man page will also
be useful to anyone who wants to run your function in `R`.

This command will open the man page (`multiplyTwoNumbers.Rd`) in
`RStudio`'s editor:


```r
file.edit(system.file("manpages", "multiplyTwoNumbers.Rd", package = "RGalaxy.lab"))
```




```r
help(package = "RGalaxy", help_type = "html")
file.edit(system.file("doc", "RGalaxy-vignette.R", package = "RGalaxy"))
```


Now click on "User guides, package vignettes and other documentation.", then
click on "HTML" (if you like, you can right click on this link and open it in
a new window).

Galaxy is installed in `/extra/ubuntu/galaxy-dist`. Let's tell R about this:


```r
galaxyHome <- "/extra/ubuntu/galaxy-dist"
```







```r
getGalaxyUrl <- function(silent = FALSE) {
    library(httr)
    public.dns <- content(GET("http://169.254.169.254/latest/meta-data/public-hostname"))
    url <- paste0("http://", public.dns, ":8080")
    if (!silent) {
        cat("You can launch Galaxy with:\n")
        cat(paste0("browseURL(getGalaxyUrl())\n"))
        cat("Be sure popup-blockers are disabled.\n")
    }
    url
}
```


Restart Galaxy:


```r

restartGalaxy <- function(galaxyHome) {
    oldwd <- getwd()
    on.exit(setwd(oldwd))
    setwd(galaxyHome)
    processes <- system2(c("ps", "-ef"), stdout = TRUE)
    galaxyProcess <- processes[grepl("paster\\.py", processes)]
    if (length(galaxyProcess) > 1) 
        stop("More than one galaxy process running. Aborting.")
    if (length(galaxyProcess) == 0) {
        cat("Note: Galaxy is not running.\n")
    } else {
        pid <- strsplit(galaxyProcess, " +")[[1]][2]
        system2("kill", sprintf("-9 %s", pid))
    }
    system2("nohup", "./run.sh > galaxy.log 2>&1 &")
    cat("Galaxy will be restarted in a moment.\n")
}
```


