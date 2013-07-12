restartGalaxy <- function(galaxyHome)
{
    oldwd <- getwd()
    on.exit(setwd(oldwd))
    setwd(galaxyHome)
    processes <- system2(c("ps", "-ef"), stdout=TRUE)
    galaxyProcess <- processes[grepl("paster\\.py", processes)]
    galaxyProcess <- sub("^ +", "", galaxyProcess)
    if (length(galaxyProcess) > 1)
        stop("More than one galaxy process running. Aborting.")
    if (length(galaxyProcess)==0)
    {
        cat("Note: Galaxy is not running.\n")
    } else {
        pid <- strsplit(galaxyProcess, " +")[[1]][2]
        system2("kill", sprintf("-9 %s", pid))
    }
    system2("nohup", "./run.sh > galaxy.log 2>&1 &")
    cat("Galaxy will be restarted in a moment.\n")
}

getGalaxyUrl <- function(silent=FALSE)
{
    try(hostnamed <- suppressWarnings(system2(c("hostname", "-d"),
        stdout=TRUE, stderr=NULL)),
        silent=TRUE)
    if (exists("hostnamed") && length(hostnamed) &&
        grepl("ec2\\.internal", hostnamed))
    {
      library(httr)
      public.dns <-
          content(GET("http://169.254.169.254/latest/meta-data/public-hostname"))
      url <- paste0("http://", public.dns, ":8080")
    } else {
      port <- "8080"
      hostname <- system2("hostname", stdout=TRUE)
      if (grepl("^dhcp", hostname))
        port <- "8081"
      url <- sprintf("http://localhost:%s", port)
    }
    if (!silent)
    {
        cat("You can launch Galaxy with:\n")
        cat(paste0("browseURL(getGalaxyUrl())\n"))
        cat("Be sure popup-blockers are disabled.\n")
    }
    url
}

# multiplyTwoNumbers <- 
#     function(
#         number1=GalaxyNumericParam(required=TRUE),
#         number2=GalaxyNumericParam(required=TRUE),
#         product=GalaxyOutput("product", "txt"))
# {
#     cat(number1 * number2, file=product)
# }



# multiplyTwoNumbersWithTest <-
# function(
#         number1=GalaxyNumericParam(required=TRUE, testValues=5L),
#         number2=GalaxyNumericParam(required=TRUE, testValues=5L),
#         product=GalaxyOutput("sum", "txt"))
# {
#     cat(number1 * number2, file=product)
# }

# probeLookup <- function(
#     probe_ids=GalaxyCharacterParam(
#         required=TRUE,
#         testValues="1002_f_at 1003_s_at"),
#     outputfile=GalaxyOutput("probeLookup", "csv"))
# {
#     suppressPackageStartupMessages(library(hgu95av2.db))
#     ids <- strsplit(probe_ids, " ")[[1]]
#     results <- select(hgu95av2.db, keys=ids, columns=c("SYMBOL","PFAM"),
#         keytype="PROBEID")
#     write.csv(results, file=outputfile)
# }
