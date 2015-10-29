f <- "make.log"
sink(f)
rmarkdown::render("MASTER.Rmd")
file.copy("MASTER.html", "index.html", overwrite=TRUE)
file.info("index.html")
sink(NULL)
