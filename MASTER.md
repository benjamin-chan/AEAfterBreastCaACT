# Adverse Events after Adjuvent Chemotherapy for Breast Cancer
[Benjamin Chan](http://careers.stackoverflow.com/benjaminchan)  
`r Sys.time()`  

# Background

See the project [wiki](https://github.com/benjamin-chan/AEAfterBreastCaACT/wiki).


# Scripts

Sequence of scripts:

<!--html_preserve--><div id="htmlwidget-9877" style="width:192px;height:480px;" class="grViz"></div>
<script type="application/json" data-for="htmlwidget-9877">{ "x": {
 "diagram": "digraph {\n\ngraph [layout=dot]\n\nnode [fontname=\"Lato\"]\n\n  \"a\" [label = \"prologue.Rmd\", style = \"filled\", fontcolor = \"white\", color = \"#014386ff\", shape = \"oval\"] \n  \"b\" [label = \"replicateOno.Rmd\", style = \"filled\", fontcolor = \"white\", color = \"#014386ff\", shape = \"oval\"] \n  \"c\" [label = \"readAhles.Rmd\", style = \"filled\", fontcolor = \"white\", color = \"#014386ff\", shape = \"oval\"] \n  \"d\" [label = \"readTager.Rmd\", style = \"filled\", fontcolor = \"white\", color = \"#014386ff\", shape = \"oval\"] \n  \"e\" [label = \"combineData.Rmd\", style = \"filled\", fontcolor = \"white\", color = \"#014386ff\", shape = \"oval\"] \n  \"f\" [label = \"epilogue.Rmd\", style = \"filled\", fontcolor = \"white\", color = \"#014386ff\", shape = \"oval\"] \n  \"a\"->\"b\" \n  \"b\"->\"c\" \n  \"c\"->\"d\" \n  \"d\"->\"e\" \n  \"e\"->\"f\" \n}",
"config": {
 "engine": "dot",
"options": null 
} 
},"evals": [  ] }</script><!--/html_preserve-->


# Prologue

1. Set path of input data sources
1. Load [`devtools`](https://github.com/hadley/devtools)
1. Source the [`loadPkg`](https://gist.github.com/benjamin-chan/3b59313e8347fffea425) function
1. Load packages
1. Source the [`makeMetadata`](https://gist.github.com/benjamin-chan/091209ab4eee1f171540) function
1. Start the job timer


```
## Sourcing https://gist.githubusercontent.com/benjamin-chan/3b59313e8347fffea425/raw/c03cd15480a6444399ff5f34892f5911d6e12b44/loadPkg.R
## SHA-1 hash of file is 0bb1bb041c1dda15ee613db701d0c5784d1196a5
## Sourcing https://gist.githubusercontent.com/benjamin-chan/091209ab4eee1f171540/raw/156a5e29111d0da6ec5693f5a881628e10fb9613/makeMetadata.R
## SHA-1 hash of file is 8b07ca14d3606ec83f76e636e7f9088e73a003b0
```

# Replicate Ono

Replicate data from 
[Ono, Miyuki, et al.](http://www.ncbi.nlm.nih.gov/pmc/articles/PMC4354286/)
"A Meta-Analysis of Cognitive Impairment and Decline Associated with Adjuvant Chemotherapy in Women with Breast Cancer."
*Front Oncol.* 
2015; 5: 59. 

Data file was requested and received from the co-author, [James Ogilvie](https://www.griffith.edu.au/health/school-applied-psychology/rhd-students/james-ogilvie), in October 2015.

The `DOMAINFORMETAkvd` field (column AG) was coded by Kathleen Van Dyk <KVanDyk@mednet.ucla.edu>.

```
From: Van Dyk, Kathleen [KVanDyk@mednet.ucla.edu]
Sent: Tuesday, November 03, 2015 5:08 PM
To: Ayse Tezcan
Cc: Benjamin Chan
Subject: RE: Cognitive impairment draft paper

Hi,
 
Attached is the Ono spreadsheet with a new column with my suggestions for
domains and domains for each Ahles test is in sheet 2.  I've highlighted tests
that we may want to exclude if we want to consistently keep one or two
measures per test.  Ben --- does it matter statistically if there is more than
one measure from the same test (for example delayed recall and delayed
recognition) in the same domain?  In almost every case we have total and delay
for memory tests but if we add in more measures (Trial 6, Supraspan,
Recognition) does this confound analyses because these are likely highly
correlated measures within the same test?  Would all of the studies need to
use the same measures in each test (i.e., every study uses Total and Delay)?
I might not be asking this clearly --- let me know what you think.
```

Read data file.


```r
f <- sprintf("%s/%s", pathIn, "Requested Chemo Data domains kvd 11.19.15 2.xlsx")
message(sprintf("File: %s\nModification date: %s\nFile size: %.1f bytes",
                f,
                file.mtime(f),
                file.size(f)))
```

```
## File: StudyDocuments/CognitiveImpairment/Requested Chemo Data domains kvd 11.19.15 2.xlsx
## Modification date: 2015-11-19 20:36:53
## File size: 178940.0 bytes
```

```r
D0 <- read.xlsx(f, sheet=1, check.names=TRUE)
D0 <- data.table(D0)
```

Show a map of the column names and locations.


```r
colNames <- data.frame(colNum = 1:ncol(D0),
                       colCell = c(LETTERS,
                                   sprintf("%s%s", LETTERS[1], LETTERS),
                                   sprintf("%s%s", LETTERS[2], LETTERS),
                                   sprintf("%s%s", LETTERS[3], LETTERS))[1:ncol(D0)],
                       varName = names(D0))
colNames
```

```
##    colNum colCell                  varName
## 1       1       A               First.Auth
## 2       2       B                Study.Ref
## 3       3       C                 Pub.Year
## 4       4       D                 Cog.Test
## 5       5       E    DOMAIN.FOR.META..kvd.
## 6       6       F                  Journal
## 7       7       G                 Pre.Meta
## 8       8       H                   Design
## 9       9       I                 Comp.Grp
## 10     10       J            Healthy_GROUP
## 11     11       K                   Tx.Grp
## 12     12       L   Pre.Post.Time.Interval
## 13     13       M                  Time.SD
## 14     14       N                     Tx.N
## 15     15       O                    Ctl.N
## 16     16       P                  Total.N
## 17     17       Q                   Tx.Age
## 18     18       R                Tx.Age.SD
## 19     19       S                  Ctl.Age
## 20     20       T               Ctl.Age.SD
## 21     21       U                    Tx.IQ
## 22     22       V                 Tx.IQ.SD
## 23     23       W                   Ctl.IQ
## 24     24       X                Ctl.IQ.SD
## 25     25       Y                  IQ.Note
## 26     26       Z                   Tx.EDU
## 27     27      AA                Tx.EDU.SD
## 28     28      AB                  Ctl.EDU
## 29     29      AC               Ctl.EDU.SD
## 30     30      AD                 EDU.Note
## 31     31      AE             Tx.Chem.Time
## 32     32      AF          Tx.Chem.Time.SD
## 33     33      AG Cognitive.Domain.Primary
## 34     34      AH                Score.Typ
## 35     35      AI                     Tx.M
## 36     36      AJ                    Tx.SD
## 37     37      AK                    Ctl.M
## 38     38      AL                   Ctl.SD
## 39     39      AM             Direct.Notes
## 40     40      AN                    X1.X2
## 41     41      AO                   Tx.N.1
## 42     42      AP                  Ctl.N.1
## 43     43      AQ                  Tx.SD.2
## 44     44      AR                 Ctl.SD.2
## 45     45      AS                  Spooled
## 46     46      AT                Cohen.s.d
## 47     47      AU                 Hedges.g
## 48     48      AV                     Var1
## 49     49      AW                     Var2
## 50     50      AX                 Variance
## 51     51      AY           Standard.Error
## 52     52      AZ                   Weight
## 53     53      BA                     w.ES
## 54     54      BB                   w.ES.2
## 55     55      BC                      w.2
## 56     56      BD                  StudyES
## 57     57      BE                  StudySE
## 58     58      BF                        z
## 59     59      BG                  LowerCI
## 60     60      BH                  UpperCI
## 61     61      BI                        Q
## 62     62      BJ                       df
## 63     63      BK               Q.Critical
## 64     64      BL           Q.Sig...p..05.
## 65     65      BM            RANDOM.EFFECT
## 66     66      BN                     RE_w
## 67     67      BO                   w.ES.1
## 68     68      BP                 w.ES.2.1
## 69     69      BQ                    w.2.1
## 70     70      BR                StudyES.1
## 71     71      BS                StudySE.1
## 72     72      BT                      z.1
## 73     73      BU                LowerCI.1
## 74     74      BV                UpperCI.1
## 75     75      BW                      Q.1
## 76     76      BX                     df.1
## 77     77      BY             Q.Critical.1
## 78     78      BZ         Q.Sig...p..05..1
## 79     79      CA                I.2.Fixed
## 80     80      CB               I.2.Random
```

Put the summary rows in a separate data table, `DOno`.


```r
DOno <- D0[is.na(First.Auth) & !is.na(Weight), c(52:ncol(D0)), with=FALSE]
```

Put the instrument-level rows in a separate data table, `D`.
Only keep the columns needed to calculate fixed and random effects statistics.

The `RANDOM.EFFECT` column was specific to the Ono analysis.
The value in the Ono spreadsheet will be different for our use.

```
From: James Ogilvie [j.ogilvie@griffith.edu.au]
Sent: Sunday, October 18, 2015 5:42 PM
To: Benjamin Chan
Cc: 'jamelnikow@ucdavis.edu'; 'm.ono@griffith.edu.au'; 'd.shum@griffith.edu.au'; Ayse Tezcan (aztezcan@ucdavis.edu); Meghan Soulsby (masoulsby@ucdavis.edu)
Subject: Re: Fwd: request for data from your recently published meta-analysis

Hi Benjamin,

Thanks for contacting me regarding this issue. I had wondered whether Dr. Melnikow had received the data I had sent, as I had not received confirmation of my email containing the data.

These are very good questions! It took me a while to get my head around the random effect model when performing this analysis. I am attaching an article that I found very useful in coming to terms with the model - hopefully you will find this useful too.

To answer your questions,   is a constant across a pool of studies that you wish to examine and generate summary/aggregate statistics (e.g., grand mean effect size). Therefore, the value of the constant will change depending on the the specific pool of studies examined. It is calculated across the total pool of studies.

  is the total Q statistic (assessing heterogeneity) that is calculated across ALL studies and relates to the grand mean effect size. It is not the same as the Q statistic in column BH. There is a Q statistic for each study (this is the Q in column BH), as well as a Q statistic for all studies pooled together (this being the  statistic). The formula for calculating the Q statistic are provided in the pdf I've attached titled "Heterogeneity in MA".

As I've mentioned, the value of   is specific to the pool of studies you are examining. Therefore, the  value to calculate effect sizes according to a random effects model will be different for your analyses - assuming you have a different pool of studies that you are including in the analyses. Given this, the  value in column BL needs to be updated by you to be specific to the pool of studies you are looking at.
```


```r
importantVar <- c(1, 9:12, 14:17, 19, 35:39, 65, 33, 4, 5, 34)
authors <- c("Bender", "Collins", "Jenkins", "Wefel")
D <- D0[First.Auth %in% authors, importantVar, with=FALSE]
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
           "randomEffect",  # Keep the value from Ono for verification purposes; do not use for analysis
           gsub("\\.", "", names(D0)[c(33, 4, 5, 34)])))
setnames(D, "DOMAINFORMETAkvd", "CognitiveDomainForMetaAnalysis")
```

The data in the received file is in the form of longitudinal means and standard deviations.


```r
D
```

```
##      author                           comparisonGroup healthyGroup
##   1: Bender One week after completion of chemotherapy            1
##   2: Bender One week after completion of chemotherapy            1
##   3: Bender One week after completion of chemotherapy            1
##   4: Bender One week after completion of chemotherapy            1
##   5: Bender One week after completion of chemotherapy            1
##  ---                                                              
## 126:  Wefel               Chemotherapy one year after            1
## 127:  Wefel                                        NA           NA
## 128:  Wefel                                        NA           NA
## 129:  Wefel                                        NA           NA
## 130:  Wefel                                        NA           NA
##                treatmentGroup timeDays nGroup1 nGroup2 nTotal ageGroup1
##   1: Chemotherapy + Tamoxifen  182.625      19      12     31     44.13
##   2:             Chemotherapy  182.625      19      15     34     40.11
##   3: Chemotherapy + Tamoxifen  182.625      19      12     31     44.13
##   4:             Chemotherapy  182.625      19      15     34     40.11
##   5: Chemotherapy + Tamoxifen  182.625      19      12     31     44.13
##  ---                                                                   
## 126:                       NA  547.863      18      14     32     45.40
## 127:                       NA       NA      NA      NA     NA        NA
## 128:                       NA       NA      NA      NA     NA        NA
## 129:                       NA       NA      NA      NA     NA        NA
## 130:                       NA       NA      NA      NA     NA        NA
##      ageGroup2 meanGroup1 sdGroup1 meanGroup2 sdGroup2   direction
##   1:        NA      10.00     0.77      12.38     0.53 Lower worse
##   2:        NA      10.79     0.59      11.96     0.46 Lower worse
##   3:        NA      51.00     2.45      54.90     5.06 Lower worse
##   4:        NA      56.47     2.14      56.89     1.75 Lower worse
##   5:        NA      10.47     0.81      11.96     0.42 Lower worse
##  ---                                                              
## 126:        NA      11.44     2.85      12.71     3.77 Lower worse
## 127:        NA         NA       NA         NA       NA          NA
## 128:        NA         NA       NA         NA       NA          NA
## 129:        NA         NA       NA         NA       NA          NA
## 130:        NA         NA       NA         NA       NA          NA
##      randomEffect CognitiveDomainPrimary                CogTest
##   1:     0.161462                    LTM    RAVL delayed recall
##   2:     0.161462                    LTM    RAVL delayed recall
##   3:     0.161462                    LTM       RAVL total score
##   4:     0.161462                    LTM       RAVL total score
##   5:     0.161462                    LTM           RAVL trial 6
##  ---                                                           
## 126:     0.161462           Visuospatial    WAIS-R block design
## 127:           NA                     NA VSRT Long-Term Storage
## 128:           NA                     NA   NVSRT Delayed Recall
## 129:           NA                     NA    VSRT Delayed Recall
## 130:           NA                     NA   NVSRT Delayed Recall
##      CognitiveDomainForMetaAnalysis      ScoreTyp
##   1:                  Verbal Memory     Raw score
##   2:                  Verbal Memory     Raw score
##   3:                  Verbal Memory     Raw score
##   4:                  Verbal Memory     Raw score
##   5:                  Verbal Memory     Raw score
##  ---                                             
## 126:                   Visuospatial Scaled scores
## 127:                  Verbal Memory            NA
## 128:                  Visual Memory            NA
## 129:                  Verbal Memory            NA
## 130:                  Visual Memory            NA
```

Replicate spreadsheet calculations.


```r
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
             weightFE = 1 / variance)]
D <- D[,
       `:=` (effSizeWeightedFE = weightFE * hedgesG)]
D <- D[, weightRE := 1 / (variance + randomEffect)]
D <- D[, effSizeWeightedRE := weightRE * hedgesG]
```

Calculate fixed effects statisitcs.


```r
DFixed <- D[!is.na(nTotal),
            .(df = .N,
              sumWeights = sum(weightFE),
              effSize = sum(effSizeWeightedFE) / sum(weightFE),
              se = sqrt(1 / sum(weightFE)),
              sumEffSizeWeighted = sum(effSizeWeightedFE),
              ssEffSizeWeighted = sum(weightFE * hedgesG ^ 2),
              ssWeights = sum(weightFE ^ 2)),
            .(author, timeDays)]
DFixed <- DFixed[,
                 `:=` (z = effSize / se,
                       lowerCI = effSize + qnorm(0.025) * se,
                       upperCI = effSize + qnorm(0.975) * se,
                       Q = ssEffSizeWeighted - (sumEffSizeWeighted ^ 2 / sumWeights),
                       criticalValue = qchisq(0.05, df, lower.tail=FALSE))]
DFixed <- DFixed[,
                 `:=` (pvalue = pchisq(Q, df, lower.tail=FALSE),
                       Isq = 100 * ((Q - df) / Q))]
```

Check if my calculations agree with Ono's.


```r
isCheckFixedPassed <- all.equal(DOno[, .(StudyES, z, Q)], 
                                DFixed[, .(effSize, z, Q)],
                                check.names=FALSE)
message(sprintf("Do my FIXED effect statistic calculations agree with Ono's? %s",
                isCheckFixedPassed))
```

```
## Do my FIXED effect statistic calculations agree with Ono's? TRUE
```

```r
print(xtable(DFixed), type="html")
```

<!-- html table generated in R 3.2.1 by xtable 1.7-4 package -->
<!-- Sun Nov 22 22:27:33 2015 -->
<table border=1>
<tr> <th>  </th> <th> author </th> <th> timeDays </th> <th> df </th> <th> sumWeights </th> <th> effSize </th> <th> se </th> <th> sumEffSizeWeighted </th> <th> ssEffSizeWeighted </th> <th> ssWeights </th> <th> z </th> <th> lowerCI </th> <th> upperCI </th> <th> Q </th> <th> criticalValue </th> <th> pvalue </th> <th> Isq </th>  </tr>
  <tr> <td align="right"> 1 </td> <td> Bender </td> <td align="right"> 182.62 </td> <td align="right">  16 </td> <td align="right"> 96.80 </td> <td align="right"> 1.02 </td> <td align="right"> 0.10 </td> <td align="right"> 98.53 </td> <td align="right"> 241.49 </td> <td align="right"> 626.88 </td> <td align="right"> 10.01 </td> <td align="right"> 0.82 </td> <td align="right"> 1.22 </td> <td align="right"> 141.21 </td> <td align="right"> 26.30 </td> <td align="right"> 0.00 </td> <td align="right"> 88.67 </td> </tr>
  <tr> <td align="right"> 2 </td> <td> Bender </td> <td align="right"> 547.50 </td> <td align="right">  16 </td> <td align="right"> 63.53 </td> <td align="right"> 0.55 </td> <td align="right"> 0.13 </td> <td align="right"> 34.76 </td> <td align="right"> 285.90 </td> <td align="right"> 290.59 </td> <td align="right"> 4.36 </td> <td align="right"> 0.30 </td> <td align="right"> 0.79 </td> <td align="right"> 266.88 </td> <td align="right"> 26.30 </td> <td align="right"> 0.00 </td> <td align="right"> 94.00 </td> </tr>
  <tr> <td align="right"> 3 </td> <td> Collins </td> <td align="right"> 537.90 </td> <td align="right">  23 </td> <td align="right"> 604.56 </td> <td align="right"> 0.21 </td> <td align="right"> 0.04 </td> <td align="right"> 124.90 </td> <td align="right"> 39.49 </td> <td align="right"> 15893.07 </td> <td align="right"> 5.08 </td> <td align="right"> 0.13 </td> <td align="right"> 0.29 </td> <td align="right"> 13.69 </td> <td align="right"> 35.17 </td> <td align="right"> 0.94 </td> <td align="right"> -68.01 </td> </tr>
  <tr> <td align="right"> 4 </td> <td> Collins </td> <td align="right"> 146.50 </td> <td align="right">  23 </td> <td align="right"> 607.30 </td> <td align="right"> 0.10 </td> <td align="right"> 0.04 </td> <td align="right"> 58.14 </td> <td align="right"> 17.63 </td> <td align="right"> 16035.80 </td> <td align="right"> 2.36 </td> <td align="right"> 0.02 </td> <td align="right"> 0.18 </td> <td align="right"> 12.07 </td> <td align="right"> 35.17 </td> <td align="right"> 0.97 </td> <td align="right"> -90.58 </td> </tr>
  <tr> <td align="right"> 5 </td> <td> Jenkins </td> <td align="right"> 364.00 </td> <td align="right">  14 </td> <td align="right"> 592.05 </td> <td align="right"> 0.08 </td> <td align="right"> 0.04 </td> <td align="right"> 47.58 </td> <td align="right"> 23.62 </td> <td align="right"> 25038.13 </td> <td align="right"> 1.96 </td> <td align="right"> -0.00 </td> <td align="right"> 0.16 </td> <td align="right"> 19.79 </td> <td align="right"> 23.68 </td> <td align="right"> 0.14 </td> <td align="right"> 29.27 </td> </tr>
  <tr> <td align="right"> 6 </td> <td> Jenkins </td> <td align="right"> 28.00 </td> <td align="right">  14 </td> <td align="right"> 593.46 </td> <td align="right"> 0.03 </td> <td align="right"> 0.04 </td> <td align="right"> 19.46 </td> <td align="right"> 12.29 </td> <td align="right"> 25157.32 </td> <td align="right"> 0.80 </td> <td align="right"> -0.05 </td> <td align="right"> 0.11 </td> <td align="right"> 11.65 </td> <td align="right"> 23.68 </td> <td align="right"> 0.63 </td> <td align="right"> -20.17 </td> </tr>
  <tr> <td align="right"> 7 </td> <td> Wefel </td> <td align="right"> 182.62 </td> <td align="right">  10 </td> <td align="right"> 89.09 </td> <td align="right"> 0.18 </td> <td align="right"> 0.11 </td> <td align="right"> 15.73 </td> <td align="right"> 5.24 </td> <td align="right"> 793.76 </td> <td align="right"> 1.67 </td> <td align="right"> -0.03 </td> <td align="right"> 0.38 </td> <td align="right"> 2.47 </td> <td align="right"> 18.31 </td> <td align="right"> 0.99 </td> <td align="right"> -305.57 </td> </tr>
  <tr> <td align="right"> 8 </td> <td> Wefel </td> <td align="right"> 547.86 </td> <td align="right">  10 </td> <td align="right"> 79.52 </td> <td align="right"> 0.26 </td> <td align="right"> 0.11 </td> <td align="right"> 20.75 </td> <td align="right"> 8.62 </td> <td align="right"> 632.66 </td> <td align="right"> 2.33 </td> <td align="right"> 0.04 </td> <td align="right"> 0.48 </td> <td align="right"> 3.20 </td> <td align="right"> 18.31 </td> <td align="right"> 0.98 </td> <td align="right"> -212.29 </td> </tr>
   </table>

Calculate random effects statisitcs.


```r
DRandom <- D[!is.na(nTotal),
             .(df = .N,
               sumWeights = sum(weightRE),
               ssEffSizeWeighted = sum(weightRE * hedgesG ^ 2),
               ssWeights = sum(weightRE ^ 2),
               sumEffSizeWeighted = sum(effSizeWeightedRE),
               effSize = sum(effSizeWeightedRE) / sum(weightRE),
               se = sqrt(1 / sum(weightRE))),
             .(author, timeDays)]
DRandom <- DRandom[,
                   `:=` (z = effSize / se,
                         lowerCI = effSize + qnorm(0.025) * se,
                         upperCI = effSize + qnorm(0.975) * se,
                         Q = ssEffSizeWeighted - (sumEffSizeWeighted ^ 2 / sumWeights),
                         criticalValue = qchisq(0.05, df, lower.tail=FALSE))]
DRandom <- DRandom[,
                   `:=` (pvalue = pchisq(Q, df, lower.tail=FALSE),
                         Isq = 100 * ((Q - df) / Q))]
```

Check if my calculations agree with Ono's.


```r
isCheckRandomPassed <- all.equal(DOno[, c(19, 21, 24), with=FALSE], 
                                 DRandom[, .(effSize, z, Q)],
                                 check.names=FALSE)
message(sprintf("Do my RANDOM effect statistic calculations agree with Ono's? %s",
                isCheckRandomPassed))
```

```
## Do my RANDOM effect statistic calculations agree with Ono's? TRUE
```

```r
print(xtable(DRandom), type="html")
```

<!-- html table generated in R 3.2.1 by xtable 1.7-4 package -->
<!-- Sun Nov 22 22:27:33 2015 -->
<table border=1>
<tr> <th>  </th> <th> author </th> <th> timeDays </th> <th> df </th> <th> sumWeights </th> <th> ssEffSizeWeighted </th> <th> ssWeights </th> <th> sumEffSizeWeighted </th> <th> effSize </th> <th> se </th> <th> z </th> <th> lowerCI </th> <th> upperCI </th> <th> Q </th> <th> criticalValue </th> <th> pvalue </th> <th> Isq </th>  </tr>
  <tr> <td align="right"> 1 </td> <td> Bender </td> <td align="right"> 182.62 </td> <td align="right">  16 </td> <td align="right"> 48.04 </td> <td align="right"> 137.29 </td> <td align="right"> 147.43 </td> <td align="right"> 53.60 </td> <td align="right"> 1.12 </td> <td align="right"> 0.14 </td> <td align="right"> 7.73 </td> <td align="right"> 0.83 </td> <td align="right"> 1.40 </td> <td align="right"> 77.50 </td> <td align="right"> 26.30 </td> <td align="right"> 0.00 </td> <td align="right"> 79.35 </td> </tr>
  <tr> <td align="right"> 2 </td> <td> Bender </td> <td align="right"> 547.50 </td> <td align="right">  16 </td> <td align="right"> 37.25 </td> <td align="right"> 199.95 </td> <td align="right"> 92.56 </td> <td align="right"> 26.23 </td> <td align="right"> 0.70 </td> <td align="right"> 0.16 </td> <td align="right"> 4.30 </td> <td align="right"> 0.38 </td> <td align="right"> 1.03 </td> <td align="right"> 181.48 </td> <td align="right"> 26.30 </td> <td align="right"> 0.00 </td> <td align="right"> 91.18 </td> </tr>
  <tr> <td align="right"> 3 </td> <td> Collins </td> <td align="right"> 537.90 </td> <td align="right">  23 </td> <td align="right"> 115.28 </td> <td align="right"> 7.62 </td> <td align="right"> 577.83 </td> <td align="right"> 23.96 </td> <td align="right"> 0.21 </td> <td align="right"> 0.09 </td> <td align="right"> 2.23 </td> <td align="right"> 0.03 </td> <td align="right"> 0.39 </td> <td align="right"> 2.64 </td> <td align="right"> 35.17 </td> <td align="right"> 1.00 </td> <td align="right"> -770.38 </td> </tr>
  <tr> <td align="right"> 4 </td> <td> Collins </td> <td align="right"> 146.50 </td> <td align="right">  23 </td> <td align="right"> 115.38 </td> <td align="right"> 3.38 </td> <td align="right"> 578.84 </td> <td align="right"> 11.11 </td> <td align="right"> 0.10 </td> <td align="right"> 0.09 </td> <td align="right"> 1.03 </td> <td align="right"> -0.09 </td> <td align="right"> 0.28 </td> <td align="right"> 2.31 </td> <td align="right"> 35.17 </td> <td align="right"> 1.00 </td> <td align="right"> -895.09 </td> </tr>
  <tr> <td align="right"> 5 </td> <td> Jenkins </td> <td align="right"> 364.00 </td> <td align="right">  14 </td> <td align="right"> 75.63 </td> <td align="right"> 3.04 </td> <td align="right"> 408.57 </td> <td align="right"> 6.11 </td> <td align="right"> 0.08 </td> <td align="right"> 0.11 </td> <td align="right"> 0.70 </td> <td align="right"> -0.14 </td> <td align="right"> 0.31 </td> <td align="right"> 2.54 </td> <td align="right"> 23.68 </td> <td align="right"> 1.00 </td> <td align="right"> -450.68 </td> </tr>
  <tr> <td align="right"> 6 </td> <td> Jenkins </td> <td align="right"> 28.00 </td> <td align="right">  14 </td> <td align="right"> 75.65 </td> <td align="right"> 1.57 </td> <td align="right"> 408.83 </td> <td align="right"> 2.50 </td> <td align="right"> 0.03 </td> <td align="right"> 0.11 </td> <td align="right"> 0.29 </td> <td align="right"> -0.19 </td> <td align="right"> 0.26 </td> <td align="right"> 1.49 </td> <td align="right"> 23.68 </td> <td align="right"> 1.00 </td> <td align="right"> -840.71 </td> </tr>
  <tr> <td align="right"> 7 </td> <td> Wefel </td> <td align="right"> 182.62 </td> <td align="right">  10 </td> <td align="right"> 36.53 </td> <td align="right"> 2.16 </td> <td align="right"> 133.47 </td> <td align="right"> 6.48 </td> <td align="right"> 0.18 </td> <td align="right"> 0.17 </td> <td align="right"> 1.07 </td> <td align="right"> -0.15 </td> <td align="right"> 0.50 </td> <td align="right"> 1.01 </td> <td align="right"> 18.31 </td> <td align="right"> 1.00 </td> <td align="right"> -890.02 </td> </tr>
  <tr> <td align="right"> 8 </td> <td> Wefel </td> <td align="right"> 547.86 </td> <td align="right">  10 </td> <td align="right"> 34.81 </td> <td align="right"> 3.79 </td> <td align="right"> 121.21 </td> <td align="right"> 9.12 </td> <td align="right"> 0.26 </td> <td align="right"> 0.17 </td> <td align="right"> 1.55 </td> <td align="right"> -0.07 </td> <td align="right"> 0.59 </td> <td align="right"> 1.41 </td> <td align="right"> 18.31 </td> <td align="right"> 1.00 </td> <td align="right"> -611.34 </td> </tr>
   </table>

Exclude tests Kathleen determined to be not useful.

```
From: Van Dyk, Kathleen [KVanDyk@mednet.ucla.edu]
Sent: Thursday, November 19, 2015 10:22 AM
To: Benjamin Chan
Cc: Ayse Tezcan
Subject: RE: Cognitive impairment draft paper

Hi Ben,
 
Ok --- attached is the Ono spreadsheet with my suggested domains.  I did
strikethrough for the measures we probably shouldn't include at all in the
domains to keep it somewhat uniform across tests (i.e., some folks used Trial
1 from a list-learning test, some just used Total and Delay, etc.).
```


```r
strikethrough <- c("RAVL trial 6",
                   "CVLT Trial 1",
                   "RVLT trial 1",
                   "AVLT supraspan")
D <- D[!(CogTest %in% strikethrough)]
```

Domains and tests.


```r
D[,
  .N,
  .(CognitiveDomainForMetaAnalysis,
    CognitiveDomainPrimary,
    CogTest)][order(CognitiveDomainForMetaAnalysis,
                    CognitiveDomainPrimary,
                    CogTest)]
```

```
##     CognitiveDomainForMetaAnalysis CognitiveDomainPrimary
##  1:     Attn/Wkg Mem/Concentration              Attention
##  2:     Attn/Wkg Mem/Concentration              Attention
##  3:     Attn/Wkg Mem/Concentration              Attention
##  4:     Attn/Wkg Mem/Concentration              Attention
##  5:     Attn/Wkg Mem/Concentration              Attention
##  6:     Attn/Wkg Mem/Concentration              Attention
##  7:     Attn/Wkg Mem/Concentration              Attention
##  8:     Attn/Wkg Mem/Concentration              Attention
##  9:     Attn/Wkg Mem/Concentration              Attention
## 10:     Attn/Wkg Mem/Concentration              Attention
## 11:     Attn/Wkg Mem/Concentration              Attention
## 12:     Attn/Wkg Mem/Concentration     Executive Function
## 13:     Attn/Wkg Mem/Concentration                    LTM
## 14:     Attn/Wkg Mem/Concentration                    STM
## 15:     Attn/Wkg Mem/Concentration                    STM
## 16:     Attn/Wkg Mem/Concentration                    STM
## 17:     Attn/Wkg Mem/Concentration                    STM
## 18:     Attn/Wkg Mem/Concentration                    STM
## 19:     Attn/Wkg Mem/Concentration                    STM
## 20:                       Exec Fxn     Executive Function
## 21:                       Exec Fxn     Executive Function
## 22:                       Exec Fxn     Executive Function
## 23:                       Exec Fxn     Executive Function
## 24:                       Exec Fxn               Language
## 25:         Information Proc Speed              Attention
## 26:         Information Proc Speed              Attention
## 27:         Information Proc Speed             Processing
## 28:         Information Proc Speed             Processing
## 29:         Information Proc Speed             Processing
## 30:                    Motor Speed                  Motor
## 31:                    Motor Speed                  Motor
## 32:                    Motor Speed                  Motor
## 33:        Verbal Ability/Language     Executive Function
## 34:        Verbal Ability/Language     Executive Function
## 35:        Verbal Ability/Language               Language
## 36:                  Verbal Memory                    LTM
## 37:                  Verbal Memory                    LTM
## 38:                  Verbal Memory                    LTM
## 39:                  Verbal Memory                    LTM
## 40:                  Verbal Memory                    LTM
## 41:                  Verbal Memory                    LTM
## 42:                  Verbal Memory                    LTM
## 43:                  Verbal Memory                    STM
## 44:                  Verbal Memory                    STM
## 45:                  Verbal Memory                     NA
## 46:                  Verbal Memory                     NA
## 47:                  Visual Memory                    LTM
## 48:                  Visual Memory                    LTM
## 49:                  Visual Memory                    LTM
## 50:                  Visual Memory                    LTM
## 51:                  Visual Memory                    LTM
## 52:                  Visual Memory                    STM
## 53:                  Visual Memory                    STM
## 54:                  Visual Memory                     NA
## 55:                   Visuospatial           Visuospatial
## 56:                   Visuospatial           Visuospatial
##     CognitiveDomainForMetaAnalysis CognitiveDomainPrimary
##                                CogTest N
##  1:               WAIS-III -Arithmetic 2
##  2:               PASAT number correct 2
##  3:                    TMT part A time 2
##  4:                           Trails A 2
##  5:                WAIS-III Digit span 2
##  6:                  WAIS-R arithmetic 2
##  7:                  WAIS-R digit span 2
##  8:       WMS-III digit span backwards 2
##  9:         WMS-III digit span forward 2
## 10:     WMS-III spatial span backwards 2
## 11:      WMS-III spatial span forwards 2
## 12:                 Consonant trigrams 2
## 13:              Spatial span: WMS-III 2
## 14:                       4WSTM 15 sec 4
## 15:                       4WSTM 30 sec 4
## 16:                        4WSTM 5 sec 4
## 17: Letter-number sequencing: WAIS-III 1
## 18:  WAIS-III Letter-number sequencing 1
## 19:   WMS-III letter number sequencing 2
## 20:                             Stroop 2
## 21:                    TMT part B time 2
## 22:                           Trails B 2
## 23:       WCST sorts divided by trials 2
## 24:                WAIS-R similarities 2
## 25:       WAIS-III Digit Symbol Coding 2
## 26:                WAIS-R digit symbol 2
## 27:                Letter cancellation 2
## 28:            Symbol search: WAIS-III 1
## 29:             WAIS-III Symbol search 1
## 30:             Grooved Peg Board time 2
## 31:     Grooved pegboard dominant hand 2
## 32:  Grooved pegboard nondominant hand 2
## 33:  Verbal Fluency FAS number correct 2
## 34:       Verbal fluency COWAT correct 2
## 35:  Boston Naming Test number correct 2
## 36:                       AVLT delayed 2
## 37:                CVLT delayed recall 2
## 38:           CVLT delayed recognition 2
## 39:                RAVL delayed recall 4
## 40:                   RAVL total score 4
## 41:          WMS-III Logical memory II 2
## 42:       WMS-III Story delayed recall 2
## 43:                         AVLT total 2
## 44:     WMS-III Story immediate recall 2
## 45:                VSRT Delayed Recall 1
## 46:             VSRT Long-Term Storage 1
## 47:             Complex figure delayed 2
## 48:                 RCF delayed recall 4
## 49:                RVLT delayed recall 2
## 50:           RVLT delayed recognition 2
## 51:         WMS-III Family pictures II 2
## 52:           Complex figure immediate 2
## 53:               RCF immediate recall 4
## 54:               NVSRT Delayed Recall 2
## 55:              WAIS-III Block design 2
## 56:                WAIS-R block design 2
##                                CogTest N
```

Save working data tables to file if the integrity checks passed.
I don't need to save `DOno` since the integrity checks passed.


```r
metadataD = makeMetadata(D)
metadataDFixed = makeMetadata(DFixed)
metadataDRandom = makeMetadata(DRandom)
if (isCheckFixedPassed & isCheckRandomPassed) {
  f <- "Ono.RData"
  save(D,
       metadataD,
       DFixed,
       metadataDFixed,
       DRandom,
       metadataDRandom,
       file=f)
  message(sprintf("%s saved on: %s\nFile size: %s KB", 
                  f,
                  file.mtime(f),
                  file.size(f) / 1e3))
} else {
  warning(sprinf("Integrity checks failed.\n%s not saved.", f))
}
```

```
## Ono.RData saved on: 2015-11-22 22:27:34
## File size: 71.07 KB
```

# Read Ahles

Read data from 
[Ahles TA, et al.](http://www.ncbi.nlm.nih.gov/pmc/articles/PMC2988635/)
"Longitudinal Assessment of Cognitive Changes Associated With Adjuvant Treatment for Breast Cancer: Impact of Age and Cognitive Reserve."
*J Clin Oncol.* 
2010 Oct 10; 28(29): 4434-4440.

Data file was requested and received from the co-author, [Yuelin Li](https://www.mskcc.org/profile/yuelin-li), in October 2015.

Read data file (text format).


```r
f <- sprintf("%s/%s", pathIn, "Soulsby_means.txt")
message(sprintf("File: %s\nModification date: %s\nFile size: %.1f bytes",
                f,
                file.mtime(f),
                file.size(f)))
```

```
## File: StudyDocuments/CognitiveImpairment/Soulsby_means.txt
## Modification date: 2015-10-29 09:51:34
## File size: 36087.0 bytes
```

```r
D <- fread(f, sep="|")
```

The data in the received file is in the form of longitudinal means and standard deviations.


```r
D
```

```
##        txgrp    ptime NObs       Variable
##   1:   chemo baseline   60 AN_NAMES_z_adj
##   2:   chemo baseline   60   BD_RAW_z_adj
##   3:   chemo baseline   60      CFL_z_adj
##   4:   chemo baseline   60     CVLT_z_adj
##   5:   chemo baseline   60  DCCSORT_z_adj
##  ---                                     
## 416: control      2yr   39 READ_RAW_z_adj
## 417: control      2yr   39    VIGCR_z_adj
## 418: control      2yr   39    VIGFP_z_adj
## 419: control      2yr   39    VIGRT_z_adj
## 420: control      2yr   39  VOC_RAW_z_adj
##                                                   Label  N    Mean  Median
##   1: DKEFS Verbal Fluency: anival or clothing and names 60 -0.0734 -0.2300
##   2:                                 WASI: Block Design 60 -0.2050 -0.2220
##   3:                               DKEFS Verbal Fluency 60 -0.0211 -0.0655
##   4:                           CVLT-2: Trials 1-5 Total 60 -0.1900 -0.2170
##   5:        DKEFS Card Sorting: Confirmed Correct Sorts 60  0.0652  0.2660
##  ---                                                                      
## 416:                               WRAT-3 Reading Score 39  0.2470  0.3730
## 417:                  CPT: Vigilance, Correct Responses 38  0.1420  0.4320
## 418:                    CPT: Vigilance, False Positives 38 -0.3970 -0.4710
## 419:                      CPT: Vigilance, Reaction Time 38  0.1140  0.3050
## 420:                                   WASI: Vocabulary 39  0.1130  0.3870
##      StdDev
##   1:  1.263
##   2:  0.939
##   3:  1.036
##   4:  1.131
##   5:  1.059
##  ---       
## 416:  1.179
## 417:  0.728
## 418:  0.355
## 419:  0.987
## 420:  0.986
```

Study design.


```r
D[, .(nrows = .N, totalN = sum(N)), .(txgrp, ptime)]
```

```
##        txgrp    ptime nrows totalN
##  1:    chemo baseline    35   2056
##  2:    chemo   posttx    35   1886
##  3:    chemo      1yr    35   1677
##  4:    chemo      2yr    35   1549
##  5: chemo no baseline    35   2432
##  6: chemo no   posttx    35   2321
##  7: chemo no      1yr    35   2237
##  8: chemo no      2yr    35   2138
##  9:  control baseline    35   1522
## 10:  control   posttx    35   1478
## 11:  control      1yr    35   1447
## 12:  control      2yr    35   1346
```

Map `ptime` to *months after treatment*.
[Ahles TA, et al.](http://www.ncbi.nlm.nih.gov/pmc/articles/PMC2988635/) reports results in terms of

* Baseline
* 1 month after treatment
* 6 months after treatment
* 18 months after treatment

As far as I can tell, values of `ptime` map to these, although seemingly imprecise.


```r
D[ptime == "baseline", monthsPostTx := 0]
D[ptime == "posttx", monthsPostTx := 1]
D[ptime == "1yr", monthsPostTx := 6]
D[ptime == "2yr", monthsPostTx := 18]
```

Exclude

* Non-chemotherapy and control patients


```r
D <- D[txgrp == "chemo"]
```

Instruments.


```r
D[, .N, .(Variable, Label)]
```

```
##           Variable                                              Label N
##  1: AN_NAMES_z_adj DKEFS Verbal Fluency: anival or clothing and names 4
##  2:   BD_RAW_z_adj                                 WASI: Block Design 4
##  3:      CFL_z_adj                               DKEFS Verbal Fluency 4
##  4:     CVLT_z_adj                           CVLT-2: Trials 1-5 Total 4
##  5:  DCCSORT_z_adj        DKEFS Card Sorting: Confirmed Correct Sorts 4
##  6:    DCOLT_z_adj                   DKEFS Stroop: Color Patch Naming 4
##  7:     DCSC_z_adj       DKEFS Verbal Fluency: Switching Fruits/Veget 4
##  8:     DCWT_z_adj                           DKEFS Stroop: Color-Word 4
##  9:   DFSDES_z_adj                   DKEFS Card Sorting: Free Sorting 4
## 10:    DISCR_z_adj            CPT: Distractibility, Correct Responses 4
## 11:    DISFP_z_adj              CPT: Distractibility, False Positives 4
## 12:    DISRT_z_adj                CPT: Distractibility, Reaction Time 4
## 13:  DRECDES_z_adj              DKEFS: Card Sorting, Sort Recognition 4
## 14:      DST_z_adj                        DKEFS: Stroop, Set Shifting 4
## 15:  DSY_RAW_z_adj                               CVLT-2: Digit Symbol 4
## 16:   DTR1SC_z_adj           DKEFS Trails: Visual Scanning in Seconds 4
## 17:   DTR2SC_z_adj               DKEFS Trails: Number Sequencing, sec 4
## 18:   DTR3SC_z_adj               DKEFS Trails: Letter Sequencing, sec 4
## 19:   DTR4SC_z_adj         DKEFS Trails: Number-Letter Switching, sec 4
## 20:   DTR5SC_z_adj                     DKEFS Trails: Motor Speed, sec 4
## 21:    DWRDT_z_adj                    DKEFS Stroop: Word Reading, sec 4
## 22:    FACE1_z_adj                   Wechsler Memory Scale-3: Faces I 4
## 23:    FACE2_z_adj                  Wechsler Memory Scale-3: Faces II 4
## 24:  GROOVEL_z_adj              Grooved Pegboard Test: Left Hand, sec 4
## 25:  GROOVER_z_adj             Grooved Pegboard Test: Right Hand, sec 4
## 26:       LD_z_adj                     CVLT-2: Long Delay Free Recall 4
## 27:      LM1_z_adj          Wechsler Memory Scale-3: Logical Memory I 4
## 28:      LM2_z_adj         Wechsler Memory Scale-3: Logical Memory II 4
## 29:     RAO2_z_adj                       PASAT (Rao): 2 second pacing 4
## 30:     RAO3_z_adj                       PASAT (Rao): 3 second pacing 4
## 31: READ_RAW_z_adj                               WRAT-3 Reading Score 4
## 32:    VIGCR_z_adj                  CPT: Vigilance, Correct Responses 4
## 33:    VIGFP_z_adj                    CPT: Vigilance, False Positives 4
## 34:    VIGRT_z_adj                      CPT: Vigilance, Reaction Time 4
## 35:  VOC_RAW_z_adj                                   WASI: Vocabulary 4
##           Variable                                              Label N
```

Merge Kathleen's <KVanDyk@mednet.ucla.edu> domain assignments.

```
From: Van Dyk, Kathleen [KVanDyk@mednet.ucla.edu]
Sent: Tuesday, November 03, 2015 5:08 PM
To: Ayse Tezcan
Cc: Benjamin Chan
Subject: RE: Cognitive impairment draft paper

Hi,
 
Attached is the Ono spreadsheet with a new column with my suggestions for
domains and domains for each Ahles test is in sheet 2.  I've highlighted tests
that we may want to exclude if we want to consistently keep one or two
measures per test.  Ben --- does it matter statistically if there is more than
one measure from the same test (for example delayed recall and delayed
recognition) in the same domain?  In almost every case we have total and delay
for memory tests but if we add in more measures (Trial 6, Supraspan,
Recognition) does this confound analyses because these are likely highly
correlated measures within the same test?  Would all of the studies need to
use the same measures in each test (i.e., every study uses Total and Delay)?
I might not be asking this clearly --- let me know what you think.
```


```r
f <- sprintf("%s/%s", pathIn, "Requested Chemo Data domains kvd 11.19.15 2.xlsx")
message(sprintf("File: %s\nModification date: %s\nFile size: %.1f bytes",
                f,
                file.mtime(f),
                file.size(f)))
```

```
## File: StudyDocuments/CognitiveImpairment/Requested Chemo Data domains kvd 11.19.15 2.xlsx
## Modification date: 2015-11-19 20:36:53
## File size: 178940.0 bytes
```

```r
D0 <- read.xlsx(f, sheet=2, check.names=TRUE)
D0 <- data.table(D0)
CognitiveDomainForMetaAnalysis <- D0[!is.na(DOMAIN.FOR.META..kvd.), DOMAIN.FOR.META..kvd.]
lookup <- cbind(D[, .N, .(Variable, Label)], CognitiveDomainForMetaAnalysis)[, .(Variable, CognitiveDomainForMetaAnalysis)]
D <- merge(lookup, D, by="Variable")
```

Save working data tables to file.


```r
metadata = makeMetadata(D)
f <- "Ahles.RData"
save(D, metadata, file=f)
message(sprintf("%s saved on: %s\nFile size: %s KB", 
                f,
                file.mtime(f),
                file.size(f) / 1e3))
```

```
## Ahles.RData saved on: 2015-11-22 22:27:34
## File size: 22.514 KB
```

# Read Tager

Read data from 
[Tager, FA, et al.](http://link.springer.com/article/10.1007%2Fs10549-009-0606-8)
"The cognitive effects of chemotherapy in post-menopausal breast cancer patients: a controlled longitudinal study."
*Breast Cancer Res Treat.* 
  2010 Aug;123(1):25-34.

Data file was requested and received from the co-author, [Paula S. McKinley](pm491@cumc.columbia.edu), on November 20, 2015.

Read data file (SPSS format).


```r
f <- sprintf("%s/%s", pathIn, "Tager_DataForMetaAnalysis.sav")
message(sprintf("File: %s\nModification date: %s\nFile size: %.1f bytes",
                f,
                file.mtime(f),
                file.size(f)))
```

```
## File: StudyDocuments/CognitiveImpairment/Tager_DataForMetaAnalysis.sav
## Modification date: 2015-11-22 10:24:41
## File size: 102697.0 bytes
```

```r
D <- read_sav(f)
D <- data.table(D)
D <- D[,
       `:=` (session = factor(session,
                              levels = 1:4,
                              labels = c("Pre-surgery",
                                         "Post surgery before treatment",
                                         "Post treatment/6mths post surgery",
                                         "6 month follow-up")),
             chemoyn = factor(chemoyn,
                              levels= 0:1,
                              labels = c("No", "Yes")),
             CTregmen = factor(CTregmen,
                               levels = 1:3,
                               labels = c("AC",
                                          "ACT",
                                          "CMF")),
             tx = factor(tx,
                         levels = 0:11,
                         labels = c("None",
                                    "Chemo",
                                    "Radiation",
                                    "Tamoxifen",
                                    "Arimadex",
                                    "Chemo + Radiation",
                                    "Chemo + Tamoxifen",
                                    "Chemo + Arimadex",
                                    "Radiation + Tamoxifen",
                                    "Radiation + Arimadex",
                                    "Chemo + Radiation + Tamoxifen",
                                    "Chemo + Radiation + Arimadex")))]
```

Check data.


```r
D[, .N, .(chemoyn, CTregmen)]
```

```
##    chemoyn CTregmen  N
## 1:      No       NA 89
## 2:     Yes      CMF 24
## 3:     Yes      ACT 40
## 4:     Yes       AC 21
```

```r
D[, .N, .(chemoyn, chemowks)]
```

```
##    chemoyn chemowks  N
## 1:      No       88 89
## 2:     Yes       24 39
## 3:     Yes       16 14
## 4:     Yes       12  8
## 5:     Yes       28  3
## 6:     Yes       18  3
## 7:     Yes        8 12
## 8:     Yes       14  6
```

Keep *z*-score variables for these instruments.

* Finger Tapper - Dom Hand
* Finger Tapper - NonDom Hand
* Pegboard - Dom Hand
* Pegboard - Nondom Hand
* COWAT
* Boston Naming
* Trail Making A
* Trail Making B
* WAIS-III Digit Symbol
* WAIS-III Digit Span
* WAIS-III Arithmetic
* WAIS-III Number/Letter
* Rey Copy
* Buschke Total 
* Benton Visual Retention Correct


```r
measures <- c("tapdomz",
              "tapndomz",
              "pegdomz",
              "pegndomz",
              "cowz",
              "bntz",
              "trlaz",
              "trlbz",
              "dsymz",
              "dspaz",
              "aritz",
              "numz",
              "reyz",
              "bustotz",
              "bvrcoz")
```

Melt data.


```r
D <- melt(D,
          id.vars = c("subid", "session", "chemoyn", "chemowks", "CTregmen", "tx"),
          measure.vars = measures)
setnames(D, "variable", "Variable")
D <- D[Variable == "tapdomz", Label := "Finger Tapper - Dom Hand"]
D <- D[Variable == "tapndomz", Label := "Finger Tapper - NonDom Hand"]
D <- D[Variable == "pegdomz", Label := "Pegboard - Dom Hand"]
D <- D[Variable == "pegndomz", Label := "Pegboard - Nondom Hand"]
D <- D[Variable == "cowz", Label := "COWAT"]
D <- D[Variable == "bntz", Label := "Boston Naming"]
D <- D[Variable == "trlaz", Label := "Trail Making A"]
D <- D[Variable == "trlbz", Label := "Trail Making B"]
D <- D[Variable == "dsymz", Label := "WAIS-III Digit Symbol"]
D <- D[Variable == "dspaz", Label := "WAIS-III Digit Span"]
D <- D[Variable == "aritz", Label := "WAIS-III Arithmetic"]
D <- D[Variable == "numz", Label := "WAIS-III Number/Letter"]
D <- D[Variable == "reyz", Label := "Rey Copy"]
D <- D[Variable == "bustotz", Label := "Buschke Total "]
D <- D[Variable == "bvrcoz", Label := "Benton Visual Retention Correct"]
setkey(D, subid, session)
```

Exclude

* Non-chemotherapy patients
* Measurements before surgery


```r
D <- D[chemoyn != "No" &
         session != "Pre-surgery"]
D[, .N, .(chemoyn, session)]
```

```
##    chemoyn                           session   N
## 1:     Yes     Post surgery before treatment 450
## 2:     Yes Post treatment/6mths post surgery 450
## 3:     Yes                 6 month follow-up 375
```

Calculate means and standard deviations


```r
T <- D[,
       .(N = .N,
         meanZ = mean(value, na.rm=TRUE),
         sdZ = sd(value, na.rm=TRUE)),
       .(Variable,
         Label,
         session)]
setkey(T, Variable, Label, session)
```

Check against *Table 2*, column **CT Group** of [Tager, FA, et al.](http://link.springer.com/article/10.1007%2Fs10549-009-0606-8).


```r
T1 <- T[session == "Post surgery before treatment"]
T1 <- T1[, x := sprintf("%.2f (%.2f)", meanZ, sdZ)]
T1[, .(Variable, Label, N, x)]
```

```
##     Variable                           Label  N            x
##  1:  tapdomz        Finger Tapper - Dom Hand 30  1.74 (1.21)
##  2: tapndomz     Finger Tapper - NonDom Hand 30  1.38 (1.11)
##  3:  pegdomz             Pegboard - Dom Hand 30 -0.18 (1.67)
##  4: pegndomz          Pegboard - Nondom Hand 30 -0.41 (1.64)
##  5:     cowz                           COWAT 30  0.24 (0.94)
##  6:     bntz                   Boston Naming 30 -0.33 (1.48)
##  7:    trlaz                  Trail Making A 30  0.40 (1.00)
##  8:    trlbz                  Trail Making B 30  0.32 (1.18)
##  9:    dsymz           WAIS-III Digit Symbol 30  0.69 (0.98)
## 10:    dspaz             WAIS-III Digit Span 30  0.23 (0.91)
## 11:    aritz             WAIS-III Arithmetic 30  0.09 (0.92)
## 12:     numz          WAIS-III Number/Letter 30  0.34 (0.90)
## 13:     reyz                        Rey Copy 30 -1.52 (2.84)
## 14:  bustotz                  Buschke Total  30 -0.60 (1.06)
## 15:   bvrcoz Benton Visual Retention Correct 30  0.01 (1.17)
```

Map `session` to *months after treatment*.
[Tager, FA, et al.](http://link.springer.com/article/10.1007%2Fs10549-009-0606-8)

* Baseline
* 1 month after treatment
* 6 months after treatment

As far as I can tell, values of `ptime` map to these, although seemingly imprecise.


```r
D[session == "Post surgery before treatment", monthsPostTx := 0]
D[session == "Post treatment/6mths post surgery", monthsPostTx := 1]
D[session == "6 month follow-up", monthsPostTx := 6]
```

Merge Kathleen's <KVanDyk@mednet.ucla.edu> domain assignments.

```
From: Van Dyk, Kathleen [KVanDyk@mednet.ucla.edu]
Sent: Tuesday, November 03, 2015 5:08 PM
To: Ayse Tezcan
Cc: Benjamin Chan
Subject: RE: Cognitive impairment draft paper

Hi,
 
Attached is the Ono spreadsheet with a new column with my suggestions for
domains and domains for each Ahles test is in sheet 2.  I've highlighted tests
that we may want to exclude if we want to consistently keep one or two
measures per test.  Ben --- does it matter statistically if there is more than
one measure from the same test (for example delayed recall and delayed
recognition) in the same domain?  In almost every case we have total and delay
for memory tests but if we add in more measures (Trial 6, Supraspan,
Recognition) does this confound analyses because these are likely highly
correlated measures within the same test?  Would all of the studies need to
use the same measures in each test (i.e., every study uses Total and Delay)?
I might not be asking this clearly --- let me know what you think.
```


```r
f <- sprintf("%s/%s", pathIn, "Requested Chemo Data domains kvd 11.19.15 2.xlsx")
message(sprintf("File: %s\nModification date: %s\nFile size: %.1f bytes",
                f,
                file.mtime(f),
                file.size(f)))
```

```
## File: StudyDocuments/CognitiveImpairment/Requested Chemo Data domains kvd 11.19.15 2.xlsx
## Modification date: 2015-11-19 20:36:53
## File size: 178940.0 bytes
```

```r
D0 <- read.xlsx(f, sheet=1, check.names=TRUE)
D0 <- data.table(D0)
D0 <- D0[First.Auth == "Tager" & !is.na(DOMAIN.FOR.META..kvd.),
         .(Label = Cog.Test,
           CognitiveDomainForMetaAnalysis = DOMAIN.FOR.META..kvd.)]
D0 <- D0[Label == "WAIS-IIIDigit Span",
         Label := "WAIS-III Digit Span"]
lookup <- D0
T <- merge(lookup, T, by="Label")
```

Save working data tables to file.


```r
metadata = makeMetadata(T)
f <- "Tager.RData"
save(T, metadata, file=f)
message(sprintf("%s saved on: %s\nFile size: %s KB", 
                f,
                file.mtime(f),
                file.size(f) / 1e3))
```

```
## Tager.RData saved on: 2015-11-22 22:27:35
## File size: 20.398 KB
```

# Combine data from studies

Load data from

1. Ono
1. Ahles
1. Tager


```r
f <- "Ono.RData"
load(f, verbose=TRUE)
```

```
## Loading objects:
##   D
##   metadataD
##   DFixed
##   metadataDFixed
##   DRandom
##   metadataDRandom
```

```r
metadataD
```

```
## $timeStamp
## [1] "2015-11-22 22:27:33 PST"
## 
## $objectSize
## [1] "42.3 Kb"
## 
## $note
## NULL
## 
## $rowCount
## [1] 120
## 
## $colCount
## [1] 32
## 
## $colNames
##  [1] "author"                         "comparisonGroup"               
##  [3] "healthyGroup"                   "treatmentGroup"                
##  [5] "timeDays"                       "nGroup1"                       
##  [7] "nGroup2"                        "nTotal"                        
##  [9] "ageGroup1"                      "ageGroup2"                     
## [11] "meanGroup1"                     "sdGroup1"                      
## [13] "meanGroup2"                     "sdGroup2"                      
## [15] "direction"                      "randomEffect"                  
## [17] "CognitiveDomainPrimary"         "CogTest"                       
## [19] "CognitiveDomainForMetaAnalysis" "ScoreTyp"                      
## [21] "diffMean"                       "sdPooled"                      
## [23] "cohenD"                         "hedgesG"                       
## [25] "var1"                           "var2"                          
## [27] "variance"                       "se"                            
## [29] "weightFE"                       "effSizeWeightedFE"             
## [31] "weightRE"                       "effSizeWeightedRE"             
## 
## $colClasses
##                         author                comparisonGroup 
##                    "character"                    "character" 
##                   healthyGroup                 treatmentGroup 
##                      "numeric"                    "character" 
##                       timeDays                        nGroup1 
##                      "numeric"                      "numeric" 
##                        nGroup2                         nTotal 
##                      "numeric"                      "numeric" 
##                      ageGroup1                      ageGroup2 
##                      "numeric"                      "numeric" 
##                     meanGroup1                       sdGroup1 
##                      "numeric"                      "numeric" 
##                     meanGroup2                       sdGroup2 
##                      "numeric"                      "numeric" 
##                      direction                   randomEffect 
##                    "character"                      "numeric" 
##         CognitiveDomainPrimary                        CogTest 
##                    "character"                    "character" 
## CognitiveDomainForMetaAnalysis                       ScoreTyp 
##                    "character"                    "character" 
##                       diffMean                       sdPooled 
##                      "numeric"                      "numeric" 
##                         cohenD                        hedgesG 
##                      "numeric"                      "numeric" 
##                           var1                           var2 
##                      "numeric"                      "numeric" 
##                       variance                             se 
##                      "numeric"                      "numeric" 
##                       weightFE              effSizeWeightedFE 
##                      "numeric"                      "numeric" 
##                       weightRE              effSizeWeightedRE 
##                      "numeric"                      "numeric" 
## 
## $sysInfo
##        sysname        release        version       nodename        machine 
##      "Windows"        "7 x64"   "build 9200"     "FAMILYPC"       "x86-64" 
##          login           user effective_user 
##          "Ben"          "Ben"          "Ben" 
## 
## $sessionInfo
## R version 3.2.1 (2015-06-18)
## Platform: x86_64-w64-mingw32/x64 (64-bit)
## Running under: Windows 8 x64 (build 9200)
## 
## locale:
## [1] LC_COLLATE=English_United States.1252 
## [2] LC_CTYPE=English_United States.1252   
## [3] LC_MONETARY=English_United States.1252
## [4] LC_NUMERIC=C                          
## [5] LC_TIME=English_United States.1252    
## 
## attached base packages:
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
##  [1] extrafont_0.17     DiagrammeR_0.8     openxlsx_3.0.0    
##  [4] reshape2_1.4.1     haven_0.2.0        foreign_0.8-63    
##  [7] xtable_1.7-4       googlesheets_0.1.0 data.table_1.9.6  
## [10] devtools_1.7.0    
## 
## loaded via a namespace (and not attached):
##  [1] Rcpp_0.11.6       cellranger_1.0.0  formatR_1.2      
##  [4] plyr_1.8.3        bitops_1.0-6      tools_3.2.1      
##  [7] digest_0.6.8      jsonlite_0.9.16   memoise_0.2.1    
## [10] evaluate_0.8      DBI_0.3.1         rstudioapi_0.3.1 
## [13] yaml_2.1.13       parallel_3.2.1    Rttf2pt1_1.3.3   
## [16] dplyr_0.4.3       httr_0.6.1        stringr_1.0.0    
## [19] knitr_1.11        htmlwidgets_0.3.2 R6_2.0.1         
## [22] rmarkdown_0.8     RJSONIO_1.3-0     extrafontdb_1.0  
## [25] magrittr_1.5      htmltools_0.2.6   assertthat_0.1   
## [28] stringi_0.4-1     RCurl_1.95-4.6    chron_2.3-47
```

```r
D1 <- D
colNames1 <- metadataD$colNames
f <- "Ahles.RData"
load(f, verbose=TRUE)
```

```
## Loading objects:
##   D
##   metadata
```

```r
metadata
```

```
## $timeStamp
## [1] "2015-11-22 22:27:34 PST"
## 
## $objectSize
## [1] "19.4 Kb"
## 
## $note
## NULL
## 
## $rowCount
## [1] 140
## 
## $colCount
## [1] 11
## 
## $colNames
##  [1] "Variable"                       "CognitiveDomainForMetaAnalysis"
##  [3] "txgrp"                          "ptime"                         
##  [5] "NObs"                           "Label"                         
##  [7] "N"                              "Mean"                          
##  [9] "Median"                         "StdDev"                        
## [11] "monthsPostTx"                  
## 
## $colClasses
##                       Variable CognitiveDomainForMetaAnalysis 
##                    "character"                    "character" 
##                          txgrp                          ptime 
##                    "character"                    "character" 
##                           NObs                          Label 
##                      "integer"                    "character" 
##                              N                           Mean 
##                      "integer"                      "numeric" 
##                         Median                         StdDev 
##                      "numeric"                      "numeric" 
##                   monthsPostTx 
##                      "numeric" 
## 
## $sysInfo
##        sysname        release        version       nodename        machine 
##      "Windows"        "7 x64"   "build 9200"     "FAMILYPC"       "x86-64" 
##          login           user effective_user 
##          "Ben"          "Ben"          "Ben" 
## 
## $sessionInfo
## R version 3.2.1 (2015-06-18)
## Platform: x86_64-w64-mingw32/x64 (64-bit)
## Running under: Windows 8 x64 (build 9200)
## 
## locale:
## [1] LC_COLLATE=English_United States.1252 
## [2] LC_CTYPE=English_United States.1252   
## [3] LC_MONETARY=English_United States.1252
## [4] LC_NUMERIC=C                          
## [5] LC_TIME=English_United States.1252    
## 
## attached base packages:
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
##  [1] extrafont_0.17     DiagrammeR_0.8     openxlsx_3.0.0    
##  [4] reshape2_1.4.1     haven_0.2.0        foreign_0.8-63    
##  [7] xtable_1.7-4       googlesheets_0.1.0 data.table_1.9.6  
## [10] devtools_1.7.0    
## 
## loaded via a namespace (and not attached):
##  [1] Rcpp_0.11.6       cellranger_1.0.0  formatR_1.2      
##  [4] plyr_1.8.3        bitops_1.0-6      tools_3.2.1      
##  [7] digest_0.6.8      jsonlite_0.9.16   memoise_0.2.1    
## [10] evaluate_0.8      DBI_0.3.1         rstudioapi_0.3.1 
## [13] yaml_2.1.13       parallel_3.2.1    Rttf2pt1_1.3.3   
## [16] dplyr_0.4.3       httr_0.6.1        stringr_1.0.0    
## [19] knitr_1.11        htmlwidgets_0.3.2 R6_2.0.1         
## [22] rmarkdown_0.8     RJSONIO_1.3-0     extrafontdb_1.0  
## [25] magrittr_1.5      htmltools_0.2.6   assertthat_0.1   
## [28] stringi_0.4-1     RCurl_1.95-4.6    chron_2.3-47
```

```r
D2 <- D
f <- "Tager.RData"
load(f, verbose=TRUE)
```

```
## Loading objects:
##   T
##   metadata
```

```r
metadata
```

```
## $timeStamp
## [1] "2015-11-22 22:27:35 PST"
## 
## $objectSize
## [1] "7.5 Kb"
## 
## $note
## NULL
## 
## $rowCount
## [1] 42
## 
## $colCount
## [1] 7
## 
## $colNames
## [1] "Label"                          "CognitiveDomainForMetaAnalysis"
## [3] "Variable"                       "session"                       
## [5] "N"                              "meanZ"                         
## [7] "sdZ"                           
## 
## $colClasses
##                          Label CognitiveDomainForMetaAnalysis 
##                    "character"                    "character" 
##                       Variable                        session 
##                       "factor"                       "factor" 
##                              N                          meanZ 
##                      "integer"                      "numeric" 
##                            sdZ 
##                      "numeric" 
## 
## $sysInfo
##        sysname        release        version       nodename        machine 
##      "Windows"        "7 x64"   "build 9200"     "FAMILYPC"       "x86-64" 
##          login           user effective_user 
##          "Ben"          "Ben"          "Ben" 
## 
## $sessionInfo
## R version 3.2.1 (2015-06-18)
## Platform: x86_64-w64-mingw32/x64 (64-bit)
## Running under: Windows 8 x64 (build 9200)
## 
## locale:
## [1] LC_COLLATE=English_United States.1252 
## [2] LC_CTYPE=English_United States.1252   
## [3] LC_MONETARY=English_United States.1252
## [4] LC_NUMERIC=C                          
## [5] LC_TIME=English_United States.1252    
## 
## attached base packages:
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
##  [1] extrafont_0.17     DiagrammeR_0.8     openxlsx_3.0.0    
##  [4] reshape2_1.4.1     haven_0.2.0        foreign_0.8-63    
##  [7] xtable_1.7-4       googlesheets_0.1.0 data.table_1.9.6  
## [10] devtools_1.7.0    
## 
## loaded via a namespace (and not attached):
##  [1] Rcpp_0.11.6       cellranger_1.0.0  formatR_1.2      
##  [4] plyr_1.8.3        bitops_1.0-6      tools_3.2.1      
##  [7] digest_0.6.8      jsonlite_0.9.16   memoise_0.2.1    
## [10] evaluate_0.8      DBI_0.3.1         rstudioapi_0.3.1 
## [13] yaml_2.1.13       parallel_3.2.1    Rttf2pt1_1.3.3   
## [16] dplyr_0.4.3       httr_0.6.1        stringr_1.0.0    
## [19] knitr_1.11        htmlwidgets_0.3.2 R6_2.0.1         
## [22] rmarkdown_0.8     RJSONIO_1.3-0     extrafontdb_1.0  
## [25] magrittr_1.5      htmltools_0.2.6   assertthat_0.1   
## [28] stringi_0.4-1     RCurl_1.95-4.6    chron_2.3-47
```

```r
D3 <- T
```

Structure of the data should be





```r
colNames2 <- metadata$colNames
intersect(colNames1, colNames2)
colNames1
colNames2
D1
D2
D <- rbind(D1, D2, fill=TRUE)
```

Domains and tests.


```r
D[,
  .N,
  .(CognitiveDomainForMetaAnalysis,
    CognitiveDomainPrimary,
    CogTest)][order(CognitiveDomainForMetaAnalysis,
                    CognitiveDomainPrimary,
                    CogTest)]
```

Save working data tables to file.


```r
metadata = makeMetadata(D)
f <- "AllStudies.RData"
save(D, metadata, file=f)
message(sprintf("%s saved on: %s\nFile size: %s KB", 
                f,
                file.mtime(f),
                file.size(f) / 1e3))
```

# Epilogue


```
## Sourcing https://gist.githubusercontent.com/benjamin-chan/80149dd4cdb16b2760ec/raw/a1fafde5c5086024dd01d410cc2f72fb82e93f26/sessionInfo.R
## SHA-1 hash of file is 41209357693515acefb05d4b209340e744a1cbe4
```

```
## $timeStart
## [1] "2015-11-22 22:27:32"
## 
## $timeEnd
## [1] "2015-11-22 22:27:35 PST"
## 
## $timeElapsed
## [1] "3.092813 secs"
## 
## $Sys.info
##        sysname        release        version       nodename        machine 
##      "Windows"        "7 x64"   "build 9200"     "FAMILYPC"       "x86-64" 
##          login           user effective_user 
##          "Ben"          "Ben"          "Ben" 
## 
## $sessionInfo
## R version 3.2.1 (2015-06-18)
## Platform: x86_64-w64-mingw32/x64 (64-bit)
## Running under: Windows 8 x64 (build 9200)
## 
## locale:
## [1] LC_COLLATE=English_United States.1252 
## [2] LC_CTYPE=English_United States.1252   
## [3] LC_MONETARY=English_United States.1252
## [4] LC_NUMERIC=C                          
## [5] LC_TIME=English_United States.1252    
## 
## attached base packages:
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
##  [1] extrafont_0.17     DiagrammeR_0.8     openxlsx_3.0.0    
##  [4] reshape2_1.4.1     haven_0.2.0        foreign_0.8-63    
##  [7] xtable_1.7-4       googlesheets_0.1.0 data.table_1.9.6  
## [10] devtools_1.7.0    
## 
## loaded via a namespace (and not attached):
##  [1] Rcpp_0.11.6       cellranger_1.0.0  formatR_1.2      
##  [4] plyr_1.8.3        bitops_1.0-6      tools_3.2.1      
##  [7] digest_0.6.8      jsonlite_0.9.16   memoise_0.2.1    
## [10] evaluate_0.8      DBI_0.3.1         rstudioapi_0.3.1 
## [13] yaml_2.1.13       parallel_3.2.1    Rttf2pt1_1.3.3   
## [16] dplyr_0.4.3       httr_0.6.1        stringr_1.0.0    
## [19] knitr_1.11        htmlwidgets_0.3.2 R6_2.0.1         
## [22] rmarkdown_0.8     RJSONIO_1.3-0     extrafontdb_1.0  
## [25] magrittr_1.5      htmltools_0.2.6   assertthat_0.1   
## [28] stringi_0.4-1     RCurl_1.95-4.6    chron_2.3-47
```
