galaxyHome <- "/extra/ubuntu/galaxy-dist"

hostname <- system2("hostname", stdout=TRUE)
if (grepl("^dhcp", hostname))
    galaxyHome <- "/Users/dtenenba/dev/galaxy-dist"

rm(hostname)

manpage <- system.file("manpages", "multiplyTwoNumbers.Rd", package = "RGalaxy.lab")
