path <- "StudyDocuments/CognitiveImpairment"
list.files(path)
if(!require(openxlsx)) {install.packages("openxlsx")}
library(openxlsx)
library(data.table)
f <- sprintf("%s/%s", path, "Requested Chemo Data.xlsx")
D0 <- read.xlsx(f, sheet=1)
D0 <- data.table(D0)
data.frame(1:ncol(D0), names(D0))
importantVar <- c(1, 7:10, 12:15, 17, 34:38, 47:52)
D <- D0[, importantVar, with=FALSE]
setnames(D,
         names(D),
         c("author",
           "comparisonGroup",
           "healthyGroup",
           "treatmentGroup",
           "timeDays",
           "nGroup1",
           "nGroup2",
           "nTotal",
           "ageGroup1",
           "ageGroup2",
           "meanGroup1",
           "sdGroup1",
           "meanGroup2",
           "sdGroup2",
           "direction",
           "vGroup1",
           "vGroup2",
           "v",
           "se",
           "weight",
           "effsize"))
D <- D[direction == "Lower worse",
       `:=` (diffMean = meanGroup2 - meanGroup1)]
D <- D[direction == "Greater worse",
       `:=` (diffMean = meanGroup1 - meanGroup2)]
D <- D[,
       `:=` (sdPooled = sqrt((((nGroup1 - 1) * (sdGroup1 ^ 2)) +
                                ((nGroup2 - 1) * (sdGroup2 ^ 2))) /
                               (nGroup1 + nGroup2 - 2)))]
D <- D[,
       `:=` (cohenD = diffMean / sdPooled)]
D <- D[,
       `:=` (hedgesG = cohenD * (1 - (3 / ((4 * nTotal) - 9))))]
D <- D[,
       `:=` (vGroup1 = (nGroup1 + nGroup2) / (nGroup1 * nGroup2))]