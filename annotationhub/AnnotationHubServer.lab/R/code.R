
.fakeUrl <- "http://fakedatasource.org/"


fakeGTFtoGRanges <- function(recipe)
{
    file <- inputFiles(recipe)[1]
    con <- file(file)
    on.exit(close(con))
    gr <- import(con, "gtf", asRangedData=FALSE)
    save(gr, file=outputFile(recipe))
    outputFile(recipe)
}

###


FakeGtfImportPreparer <-
    setClass("FakeGtfImportPreparer", contains="ImportPreparer")

## retrieve GTF file urls from Ensembl
.ensemblGtfSourceUrls <-
    function(baseUrl)
{
    want <- .ensemblDirUrl(baseUrl, "gtf/")
    ## files in release
    unlist(lapply(want, function(url) {
        listing <- getURL(url=url, followlocation=TRUE, customrequest="LIST -R")
        listing<- strsplit(listing, "\n")[[1]]
        subdir <- sub(".* ", "", listing[grep("^drwx", listing)])
        gtfGz <- sub(".* ", "", listing[grep(".*gtf.gz$", listing)])
        sprintf("%s%s/%s", url, subdir, gtfGz)
    }), use.names=FALSE)
}



.fakeMetadataFromUrl <-
    function(sourceUrl,
             sgRegex="^([[:alpha:]_]+)\\.(.*)\\.[[:digit:]]+\\.[[:alpha:]]+")
{
    releaseRegex <- ".*(release-[[:digit:]]+).*"
    title <- sub(".gz$", "", basename(sourceUrl))
    root <- setNames(rep(NA_character_, length(sourceUrl)), title)
    species <- gsub("_", " ", sub(sgRegex, "\\1", title), fixed=TRUE)
    taxonomyId <- local({
        uspecies <- unique(species)
        .taxonomyId(uspecies)[match(species, uspecies)]
    })
    list(annotationHubRoot = root, title=title, species = species,
         taxonomyId = taxonomyId, genome = sub(sgRegex, "\\2", title),
         sourceVersion = sub(releaseRegex, "\\1", sourceUrl))
}

.taxonomyId <-
    function(species)
{
    if (!exists("speciesMap"))
        data(speciesMap, package="AnnotationHubData")
    species <- gsub(" {2,}", " ", species)
    species <- gsub(",", " ", species, fixed=TRUE)
    idx <- match(species, speciesMap$species)
    if (any(is.na(idx)))
        stop(sum(is.na(idx)), " unknown species: ",
             paste(sQuote(head(species[is.na(idx)])), collapse=" "))
    as.character(speciesMap$taxon[idx])
}


.fakeGtfMetadata <-
    function(baseUrl, sourceUrl)
{

    #sourceFile <- sourceUrl #.ensemblSourcePathFromUrl(baseUrl, sourceUrl)
    sourceFile <- sub(.fakeUrl, "", sourceUrl)
    meta <- .fakeMetadataFromUrl(sourceUrl)
    rdata <- sub(".gz$", ".RData", sourceFile)
    description <- paste("Gene Annotation for", meta$species)

    Map(AnnotationHubMetadata,
        AnnotationHubRoot=meta$annotationHubRoot,
        Description=description, Genome=meta$genome,
        SourceFile=sourceFile, SourceUrl=sourceUrl,
        SourceVersion=meta$sourceVersion, Species=meta$species,
        TaxonomyId=meta$taxonomyId, Title=meta$title,
        MoreArgs=list(
          Coordinate_1_based = TRUE,
          DataProvider = "fakedatasource.org",
          Maintainer = "Dan Tenenbaum <dtenenba@fhcrc.org>",
          RDataClass = "GRanges",
          RDataDateAdded = Sys.time(),
          RDataVersion = "0.0.1",
          Recipe = c("fakeGTFtoGRanges", package="AnnotationHubServer.lab"),
          Tags = c("GTF", "ensembl", "Gene", "Transcript", "Annotation")))
}

.ensemblBaseUrl <- "ftp://ftp.ensembl.org/pub/"


setMethod(newResources, "FakeGtfImportPreparer",
    function(importPreparer, currentMetadata = list(), ...)
{

    #sourceUrls <- .ensemblGtfSourceUrls(.ensemblBaseUrl) # 122,  6 March, 2013

    path <- system.file('gtf', package="AnnotationHubServer.lab")
    sourceUrls <- dir(path,
        pattern="\\.gtf$", recursive=TRUE)

    sourceUrls <- paste0(.fakeUrl, sourceUrls)
    ## filter known
    #knownUrls <- sapply(currentMetadata, function(elt) {
    #    metadata(elt)$SourceUrl
    #})
    #sourceUrls <- sourceUrls[!sourceUrls %in% knownUrls]

    ## AnnotationHubMetadata
    .fakeGtfMetadata(.ensemblBaseUrl, sourceUrls)
})
