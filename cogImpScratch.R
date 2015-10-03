path <- "StudyDocuments/CognitiveImpairment"
list.files(path)
if(!require(openxlsx)) {install.packages("openxlsx")}
library(openxlsx)
library(data.table)
f <- sprintf("%s/%s", path, "Requested Chemo Data.xlsx")
D0 <- read.xlsx(f, sheet=1)
D0 <- data.table(D0)
colNames <- data.frame(colNum = 1:ncol(D0),
                       colCell = c(LETTERS,
                                   sprintf("%s%s", LETTERS[1], LETTERS),
                                   sprintf("%s%s", LETTERS[2], LETTERS),
                                   sprintf("%s%s", LETTERS[3], LETTERS))[1:ncol(D0)],
                       varName = names(D0))
importantVar <- c(1, 7:10, 12:15, 17, 34:38, 64)
D <- D0[!is.na(First.Auth), importantVar, with=FALSE]
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
           "randomEffect"))  # NEED TO FIND OUT WHERE RANDOM EFFECT COMES FROM
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
       `:=` (var1 = (nGroup1 + nGroup2) / (nGroup1 * nGroup2),
             var2 = hedgesG ^ 2 / (2 * (nGroup1 + nGroup2)))]
D <- D[,
       `:=` (variance = var1 + var2)]
D <- D[,
       `:=` (se = sqrt(variance),
             weight = 1 / variance)]
D <- D[,
       `:=` (effSizeWeighted = weight * hedgesG)]

# Check
D[, .N, .(effSizeWeighted == effsize0)]
D[weight != weight0, .(author, weight, weight0, se, se0)]

DFixed <- D[,
              .(df = .N,
                sumWeights = sum(weight),
                effSize = sum(effSizeWeighted) / sum(weight),
                se = sqrt(1 / sum(weight)),
                sumEffSizeWeighted = sum(effSizeWeighted),
                ssEffSizeWeighted = sum(weight * hedgesG ^ 2),
                ssWeights = sum(weight ^ 2)),
              .(author, timeDays)]
DFixed <- DFixed[,
                 `:=` (z = effSize / se,
                       lowerCI = effSize + qnorm(0.025) * se,
                       upperCI = effSize + qnorm(0.975) * se,
                       Q = ssEffSizeWeighted - (sumEffSizeWeighted ^ 2 / sumWeights),
                       criticalValue = qchisq(0.05, df, lower.tail=FALSE))]
DFixed <- DFixed[,
                 `:=` (pvalue = pchisq(Q, df, lower.tail=FALSE))]

summarized <- D0[is.na(First.Auth), c(51:ncol(D0)), with=FALSE]
summarized <- cbind(D[, .N, .(author, timeDays)], summarized)

prec <- 15
identical(signif(summarized[, .(z, Q)], digits=prec), 
          signif(DFixed[, .(z, Q)], digits=prec))
