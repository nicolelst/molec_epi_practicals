# Molecular Epidemiology Week 3 Practical
# GWAS using PLINK

I've referred to the 12 steps/questions in `Week 3 HomeWork_PLINK.pdf` with square brackets. e.g. step 1 is marked with [1]. Feel free to search for whichever step to jump to the corresponding section.

These notes were created using the solutions in `PLINK_scripts_2024.pdf` (26-Oct-2024 10:03:43).

**PLINK** is a _module_ written in C/C++. It is also open source, so you can find the source code freely available on [GitHub](https://github.com/chrchang/plink-ng). You don't have to worry about how it was implemented (that's the great thing about modules!), you can just load this module and begin using the functions that have already been written by someone else. PLINK is a tool for GWAS, you just have to tell it what to do. To figure out how to use it, we can refer to the PLINK documentation ([v1.9](https://www.cog-genomics.org/plink/1.9/)). 

The objective is to conduct association analysis (linear regression for the quantitative measure + logistic regression for the binary outcome) on the provided genotype and phenotype data. Since the genotype data is for the genome rather than a specific candidate gene, this is a **Genome-Wide Association Study**. I could not find any documentation for the dataset we were given, so I'm not sure what phenotype we are studying exactly. It is a quantitative measurement from 91 to 298, and the sample contains individual aged above 60 (perhaps this was an inclusion criteria for the study). I am also not sure of the threshold where this measure is coded as outcomes `1` or `2` for logistic regression. 

- [Molecular Epidemiology Week 3 Practical](#molecular-epidemiology-week-3-practical)
- [GWAS using PLINK](#gwas-using-plink)
  - [Set up](#set-up)
    - [Connect to Imperial's network](#connect-to-imperials-network)
    - [Connect to HPC server via SSH](#connect-to-hpc-server-via-ssh)
    - [Create a new folder for this practical](#create-a-new-folder-for-this-practical)
  - [\[1\] Copy data files to HPC server](#1-copy-data-files-to-hpc-server)
  - [Load plink module](#load-plink-module)
  - [\[2\] Make binary PED files using the uploaded files](#2-make-binary-ped-files-using-the-uploaded-files)
  - [\[3\] Make a file including the minor allele frequency of the variants](#3-make-a-file-including-the-minor-allele-frequency-of-the-variants)
  - [\[4\] Select individuals whose IDs are in the file IDs.txt and write the data files](#4-select-individuals-whose-ids-are-in-the-file-idstxt-and-write-the-data-files)
  - [\[5\] \[6\] Extract the data and allele frequency for three SNPs: rs6681049, rs4074137, rs7540009](#5-6-extract-the-data-and-allele-frequency-for-three-snps-rs6681049-rs4074137-rs7540009)
  - [\[7\] Filter the data for a MAF \> 0.01 and HWE \< 1E-6](#7-filter-the-data-for-a-maf--001-and-hwe--1e-6)
  - [\[8\] Use the filtered data and phenotype files to conduct linear (Exercise.quantitative.pheno) and logistic regression (Exercise.pheno) analysis](#8-use-the-filtered-data-and-phenotype-files-to-conduct-linear-exercisequantitativepheno-and-logistic-regression-exercisepheno-analysis)
      - [linear regression](#linear-regression)
      - [logistic regression](#logistic-regression)
  - [\[9\] Repeat the analysis by adding age and sex to the model](#9-repeat-the-analysis-by-adding-age-and-sex-to-the-model)
      - [linear regression](#linear-regression-1)
      - [logistic regression](#logistic-regression-1)
  - [\[10\] What is the most significant SNP that you identify in linear GWAS? Is the top SNP (smallest pvalue) the same for the adjusted GWAS?](#10-what-is-the-most-significant-snp-that-you-identify-in-linear-gwas-is-the-top-snp-smallest-pvalue-the-same-for-the-adjusted-gwas)
      - [linear unadjusted model](#linear-unadjusted-model)
      - [linear adjusted model](#linear-adjusted-model)
      - [comparison of most significant SNP](#comparison-of-most-significant-snp)
  - [\[11\] Compare the beta estimate for rs10495085 in the adjusted and unadjusted GWAS.](#11-compare-the-beta-estimate-for-rs10495085-in-the-adjusted-and-unadjusted-gwas)
  - [\[12\] Which SNP has the smallest number of valid observations in linear GWAS?](#12-which-snp-has-the-smallest-number-of-valid-observations-in-linear-gwas)
  - [DONE](#done)
  - [Optional: copy all output files from the HPC server to your local machine](#optional-copy-all-output-files-from-the-hpc-server-to-your-local-machine)

## Set up 
### Connect to Imperial's network  
* Option 1: ZScaler/Tunnelblick from home
* Option 2: use the eduroam wifi network on campus

### Connect to HPC server via SSH
* Open your command line interface of choice. 
(I did this with the zsh terminal on a Mac, but Windows Powershell should work fine. Alternatively, use PuTTY and skip this section.)

* Connect to the HPC server with your login username. Replace `USERNAME` with your Imperial username.
```
ssh -XY USERNAME@login.hpc.imperial.ac.uk
```

* If prompted with `Are you sure you want to continue connecting (yes/no)?`, type `yes`. This is a standard prompt you get on your first time connecting to a new host. 

* Enter your password when prompted (nothing will appear on the screen while you're typing but this is fine)

**CHECKPOINT** - You should see the following:
```
Imperial College London Research Computing Service
--------------------------------------------------
##################################################
... bunch of text ...
```

This should also appear before your blinking cursor:
```
[USERNAME@login-a ~]$
```

### Create a new folder for this practical
Use the `mkdir` command to _make a directory_ (create a new folder).
Feel free to replace `molec_w3` with any preferred folder name. 
```
mkdir molec_w3
```
Use the `cd` command to _change working directories_ (go into the folder you just made).
```
cd molec_w3
```

**CHECKPOINT** - This should also appear before your blinking cursor:
```
[USERNAME@login-a molec_w3]$
```
You can also verify that you are in the `molec_w3` folder by showing your _present working directory_ with the `pwd` command. 
```
[USERNAME@login-a molec_w3]$ pwd
/rds/general/user/USERNAME/home/molec_w3
```

## [1] Copy data files to HPC server 
* Download the data files for the practical from Blackboard onto your local machine (the computer you are currently using). Unzip the `Week_3_sorted.zip` folder.
* Take note of where this `data` folder is saved. We will need this later. I refer to this as `DATA_PATH` in subsequent steps. It should look like `/Users/.../Week_3_sorted/Practical/data`. On a Mac, the shortcut to do this is to select the `data` folder in Finder and press Cmd+Alt+C.
* Open a **NEW** command line window/tab. (On a mac, right-click the terminal application and select "New window")
* Again, use the `cd` command to _change working directories_ to the data folder. Replace `DATA_PATH` with wherever your `data` folder is saved on your computer.
```
cd DATA_PATH
```
* Use the `scp` command to _securely copy_ the data files on your local machine to the folder you just created on the remote HPC server. Enter your password when prompted. The asterisk `*` is a wildcard (like in SQL). I use it here to copy all files (i.e. any filename) in this folder at one go (to avoid entering our password multiple times), but you can replace it with a specific filename like `IDs.txt`. 
```
scp * USERNAME@login.hpc.imperial.ac.uk:molec_w3
```
**CHECKPOINT** - You should see the following: 
```
Exercise.covar                                100% 2121    93.9KB/s   00:00    
Exercise.map                                  100% 1654KB   2.4MB/s   00:00    
Exercise.ped                                  100%   28MB   8.7MB/s   00:03    
Exercise.pheno                                100% 1068    46.6KB/s   00:00    
Exercise.quantitative.pheno                   100% 1245    20.5KB/s   00:00    
IDs.txt                                       100%   81     3.6KB/s   00:00    
SNPs.txt                                      100%   31     1.4KB/s   00:00    
```

Return to the other command line window connected to the HPC (it should say `[USERNAME@login-a molec_w3]$` before your cursor.). The rest of the practical is done with this window unless otherwise stated. 

Use the `ls` command to list the files in your current working directory, `molec_w3`. You should see all the data files for the practical have been copied to the remote HPC server. 
```
[USERNAME@login-a molec_w3]$ ls
Exercise.covar  Exercise.ped    Exercise.quantitative.pheno  SNPs.txt
Exercise.map    Exercise.pheno  IDs.txt
```

## Load plink module
The rest of the practical is done with the command line window connected to the HPC (it should say `[USERNAME@login-a molec_w3]$` before your cursor.) unless otherwise stated. 

Here we load the PLINK module, setting us up to use all its functions for GWAS.
```
module load plink
```

You can check the PLINK version with the `plink --version` command. For me this is `PLINK v1.90p 64-bit (16 Apr 2016)`. Documentation for PLINK V1.90 can be found [here](https://www.cog-genomics.org/plink/1.9/).

## [2] Make binary PED files using the uploaded files
```
plink --file Exercise --make-bed --out Exercise
```
This creates the `Exercise.bed + Exercise.bim + Exercise.fam` files. (You can verify with `ls` command.)
* `--file Exercise`: tell PLINK to use the genomic data in the text files `Exercise.ped` and `Exercise.map` (these were in the `data` folder and we copied them into `molec_w3` earlier).
* `--make-bed` specifies to create a PLINK binary fileset, as specified by [2]
* `--out Exercise`: tell PLINK to use `Exercise` as the prefix for the output file names

> **sidenote:** you don't have to run the `plink --file Exercise --recode --out Exercise.recoded` command in the practical solution. This command uses `--recode` to tell PLINK to create a new text fileset (`Exercise.recoded.ped + Exercise.recoded.map`), which can then be used in subsequent commands as an argument for the `--file` parameter. The `.ped+.map` format is NOT a native file format for PLINK 1.9 — any operation on it requires inefficient conversion to `.bed+.bim+.fam`. I guess this was just an aside for additional information. It would be useful if you want to store your dataset in a human-readable format (as opposed to a binary file). We can ignore it for this practical but you can read the documentation for `recode` [here](https://www.cog-genomics.org/plink/1.9/data#recode). 

## [3] Make a file including the minor allele frequency of the variants
```
plink --file Exercise --freq --out Exercise
```
This creates the `Exercise.frq` file.
* `--freq`: tell PLINK to create a minor allele frequency report 

Use the `head` command to _print the first lines_ of the allele frequency report saved in `Exercise.frq`. 
```
[USERNAME@login-a molec_w3]$ head Exercise.frq 
 CHR         SNP   A1   A2          MAF  NCHROBS
   1   rs6681049    1    2       0.2135      178
   1   rs4074137    1    2      0.07865      178
   1   rs7540009    0    2            0      178
   1   rs1891905    1    2       0.4045      178
   1   rs9729550    1    2       0.1292      178
   1   rs3813196    1    2      0.02809      178
   1   rs6704013    0    2            0      174
   1    rs307347    0    2            0      154
   1   rs9439440    0    2            0      174
```
> **sidenote:** by default this is the first 10 lines of the specified file. you can also specify the number of lines with the `n` parameter like `head -n 20 Exercise.frq`.

To view the full file, you can use a terminal text editor like `nano` or `vim`. I prefer nano because it's (in my opinion) simpler to use but there are some programmers/hackers who _love_ vim. 
* `nano Exercise.frq` 
* Ctrl+W to search for a specific SNP
* Ctrl+X to exit the file
* Other keyboard shortcuts are shown at the bottom of the terminal

## [4] Select individuals whose IDs are in the file IDs.txt and write the data files
You can see the individuals in the `IDs.txt` file with `nano`, `head`, or by opening the file on your own computer. First column specifies family ID (which family?), second column specifies within-family ID (which person in this family?).
```
plink --file Exercise --keep IDs.txt --make-bed --out Exercise.selected
```
From the original Exercise dataset, we have conducted :sparkles: **Sample QC** :sparkles: by selecting samples who are not related (all different Family IDs), and stored this dataset as a binary fileset (`Exercise.selected.bed + Exercise.selected.bim + Exercise.selected.fam`).
* `--keep IDs.txt`: tell PLINK which samples from the dataset to add to the `Exercise.selected` dataset (`.bed`, `.bim`, `.fam` files) by specifying the desired family IDs and within-family IDs in a space/tab-delimited text file (for us this is `IDs.txt`).

> **sidenote:** PLINK uses `keep` and `remove` to tell PLINK which samples to include in analysis (input filtering docs [here](https://www.cog-genomics.org/plink/1.9/filter))

## [5] [6] Extract the data and allele frequency for three SNPs: rs6681049, rs4074137, rs7540009
The `SNPs.txt` file has the rsIDs of each of the desired SNPs on a separate line. 
```
plink --file Exercise --extract SNPs.txt --freq --make-bed --out Exercise.SNPs
```
From the original Exercise dataset, we can specify SNPs for analysis (perhaps selected through :sparkles: **SNP QC** :sparkles:) and stored this dataset as a binary fileset (`Exercise.SNPs.bed + Exercise.SNPs.bim + Exercise.SNPs.fam`).
* `--freq`: create minor allele frequency report like in [3]
* `--extract SNPs.txt`: tell PLINK to conduct analysis only on the variant IDs specified in `SNPs.txt`

> **sidenote:** use `--exclude` instead of `--extract` to instead remove the listed variants from the current analysis (input filtering docs [here](https://www.cog-genomics.org/plink/1.9/filter))

See results in `Exercise.SNPs.frq` with `head` command
```
[USERNAME@login-a molec_w3]$ head Exercise.SNPs.frq
 CHR         SNP   A1   A2          MAF  NCHROBS
   1   rs6681049    1    2       0.2135      178
   1   rs4074137    1    2      0.07865      178
   1   rs7540009    0    2            0      178
```

## [7] Filter the data for a MAF > 0.01 and HWE < 1E-6
```
plink --file Exercise --maf 0.01 --hwe 1e-6 --make-bed --out Exercise.filter
```
From the original Exercise dataset, we have conducted :sparkles: **SNP QC** :sparkles: by filtering SNP quality based on **Minor Allele Frequency** and **Deviation from Hardy-Weinberg Equilibrium**, and stored this dataset as a binary fileset (`Exercise.selected.bed + Exercise.selected.bim + Exercise.selected.fam`).
* `maf` and `hwe` are used to specify thresholds for filtering 

From the output, we can see 
```
--hwe: 0 variants removed due to Hardy-Weinberg exact test.
16994 variants removed due to minor allele threshold(s)
(--maf/--max-maf/--mac/--max-mac).
66540 variants and 89 people pass filters and QC.
```
This dataset of filtered SNPs will be used for the subsequent analysis.

## [8] Use the filtered data and phenotype files to conduct linear (Exercise.quantitative.pheno) and logistic regression (Exercise.pheno) analysis
#### linear regression 
```
plink --bfile Exercise.filter --linear --pheno Exercise.quantitative.pheno --all-pheno --out Exercise.filter.linear
```
* `--bfile Exercise.filter`: tell PLINK to use the filtered dataset in the binary fileset we created in the previous step
* `--linear`: conduct linear regression and write a linear regression report (`.assoc.linear`, docs [here](https://www.cog-genomics.org/plink/1.9/formats#assoc_linear))
* `--pheno Exercise.quantitative.pheno`: specify file where quantitative measurements for phenotype data are matched to each sample by family ID and within-family ID. I could not find any descriptions of what phenotype we are studying in the given dataset??
* `--all-pheno`: use all phenotypes present in the `--pheno` file 
> **sidenote:** the pheno file could contain multiple columns of quantitative measurements for each individual (though in our case there is only 1 value in the `Exercise.quantitative.pheno` file). to use a different column in the pheno file for analysis, use `--mpheno` (see phenotypes docs [here](https://www.cog-genomics.org/plink/1.9/input#pheno))

Preview 10 lines of the linear regression results. 
```
[USERNAME@login-a molec_w3]$ head Exercise.filter.linear.P1.assoc.linear
 CHR         SNP         BP   A1       TEST    NMISS       BETA         STAT            P 
   1   rs6681049          1    1        ADD       89     -11.05       -1.611       0.1107
   1   rs4074137          2    1        ADD       89      13.71        1.201       0.2331
   1   rs1891905          4    1        ADD       89      5.606       0.9295       0.3552
   1   rs9729550          5    1        ADD       89     0.4766      0.05353       0.9574
   1   rs3813196          6    1        ADD       89     -9.269      -0.4716       0.6384
   1  rs12044597         11    1        ADD       89      10.01        1.401       0.1648
   1  rs10907185         12    1        ADD       89    -0.3847     -0.05383       0.9572
   1  rs11260616         13    1        ADD       88     -2.488       -0.295       0.7687
   1    rs745910         14    1        ADD       87     -11.14       -1.392       0.1676
```
* `CHR`: Chromosome code
* `SNP`: Variant identifier
* `BP`: Base-pair coordinate
* `A1`: Allele 1 (usually minor)
* `TEST`: Test identifier
* `NMISS`: Number of observations (nonmissing genotype, phenotype, and covariates)
* `BETA`: Regression coefficient 
* `STAT`: T-statistic
* `P`: Asymptotic p-value for t-statistic

#### logistic regression 
```
plink --bfile Exercise.filter --logistic --pheno Exercise.pheno --all-pheno --out Exercise.filter.logistic
```
* `--logistic`: conduct logistic regression and write a logistic regression report (`.assoc.logistic`, docs [here](https://www.cog-genomics.org/plink/1.9/formats#assoc_linear))
* `--pheno Exercise.pheno`: for logistic regression, outcome variable is discrete (yes disease/trait or no disease/trait). The Exercise.pheno file codes this as `1` or `2` for each sample identified by family ID and within-family ID. 

Preview 10 lines of the logistic regression results. 
```
[USERNAME@login-a molec_w3]$ head Exercise.filter.logistic.P1.assoc.logistic 
 CHR         SNP         BP   A1       TEST    NMISS         OR         STAT            P 
   1   rs6681049          1    1        ADD       89      0.592       -1.534       0.1251
   1   rs4074137          2    1        ADD       89      1.023      0.04235       0.9662
   1   rs1891905          4    1        ADD       89      1.033       0.1147       0.9087
   1   rs9729550          5    1        ADD       89      1.933        1.477       0.1398
   1   rs3813196          6    1        ADD       89      1.573       0.4827       0.6293
   1  rs12044597         11    1        ADD       89      1.058       0.1671       0.8673
   1  rs10907185         12    1        ADD       89      1.222       0.5964       0.5509
   1  rs11260616         13    1        ADD       88      1.251       0.5654       0.5718
   1    rs745910         14    1        ADD       87     0.6881      -0.9214       0.3568
```
* `OR`: odds ratio (number of people with the outcome/disease : number of people without it, among those with this SNP)


## [9] Repeat the analysis by adding age and sex to the model
#### linear regression 
```
plink --bfile Exercise.filter --linear --pheno Exercise.quantitative.pheno --all-pheno --covar Exercise.covar --out Exercise.filter.linear.adjusted
```
* `--covar Exercise.covar`: the `Exercise.covar` file seems like sex (`0`/`1`) and age data for each individual. Again, if we could refer to some documentation on the dataset, that would be really helpful in understanding what we are analysing.

Preview 10 lines of the linear regression results after adjusting for age and sex. 
```
[USERNAME@login-a molec_w3]$ head Exercise.filter.linear.adjusted.P1.assoc.linear
 CHR         SNP         BP   A1       TEST    NMISS       BETA         STAT            P 
   1   rs6681049          1    1        ADD       89     -12.65       -1.751       0.0835
   1   rs6681049          1    1       COV1       89     -1.171      -0.1282       0.8983
   1   rs6681049          1    1       COV2       89     0.4586       0.8181       0.4156
   1   rs4074137          2    1        ADD       89      14.02        1.213       0.2284
   1   rs4074137          2    1       COV1       89      -2.42      -0.2633        0.793
   1   rs4074137          2    1       COV2       89     0.2243       0.4122       0.6813
   1   rs1891905          4    1        ADD       89      5.892       0.9565       0.3415
   1   rs1891905          4    1       COV1       89     -1.716      -0.1857       0.8532
   1   rs1891905          4    1       COV2       89     0.2499       0.4551       0.6502
```

#### logistic regression 
```
plink --bfile Exercise.filter --logistic --pheno Exercise.pheno --all-pheno --covar Exercise.covar --out Exercise.filter.logistic.adjusted
```

Preview 10 lines of the logistic regression results after adjusting for age and sex. 
```
[USERNAME@login-a molec_w3]$ head Exercise.filter.logistic.adjusted.P1.assoc.logistic
 CHR         SNP         BP   A1       TEST    NMISS         OR         STAT            P 
   1   rs6681049          1    1        ADD       89     0.6473       -1.219       0.2227
   1   rs6681049          1    1       COV1       89     0.7866      -0.5492       0.5828
   1   rs6681049          1    1       COV2       89     0.9783      -0.8134        0.416
   1   rs4074137          2    1        ADD       89     0.9857     -0.02638        0.979
   1   rs4074137          2    1       COV1       89     0.7626      -0.6254       0.5317
   1   rs4074137          2    1       COV2       89     0.9698       -1.182       0.2371
   1   rs1891905          4    1        ADD       89      0.974     -0.09071       0.9277
   1   rs1891905          4    1       COV1       89     0.7606      -0.6301       0.5286
   1   rs1891905          4    1       COV2       89     0.9696       -1.185       0.2362
```

## [10] What is the most significant SNP that you identify in linear GWAS? Is the top SNP (smallest pvalue) the same for the adjusted GWAS?
In order to compare p-values across association analyses (e.g. linear/logistic regression), we need to use `--adjust` (docs [here](https://www.cog-genomics.org/plink/1.9/assoc#linear:~:text=%2D%2Dpfilter%20%3Cthreshold%3E-,%2D%2Dadjust,-causes%20an%20.adjusted)). This will create an `.adjusted` file (docs [here](https://www.cog-genomics.org/plink/1.9/formats#adjusted)) to be generated with each association test report, containing several basic :sparkles: **multiple testing corrections** :sparkles: for the raw p-values. Entries in this file are sorted by significance value instead of genomic location.
* `CHR`: Chromosome code. Not present with set tests.
* `SNP`: Variant/set identifier
* `UNADJ`: Unadjusted p-value (we should NOT be comparing this between models)
* `BONF`: Bonferroni correction
* `FDR_BH`: Benjamini & Hochberg (1995) step-up false discovery control
* `FDR_BY`: Benjamini & Yekutieli (2001) step-up false discovery control

> **NOTE:** the use of this `adjust` option is _not_ what the question is referring to. The "adjusted GWAS" is a model created with age and sex as covariates, using `--covar` like we did in Q9. They want us to compare the p-values for a model like in Q8 (no covariates) vs a model like in Q9 ("adjusted" for covariates). This is some tricky wording.

#### linear unadjusted model
```
plink --bfile Exercise.filter --linear --pheno Exercise.quantitative.pheno --all-pheno --adjust --out Exercise.filter.linear.sort
```
This is just like Q8 but with `adjust` for multiple testing corrections.

#### linear adjusted model 
```
plink --bfile Exercise.filter --linear --pheno Exercise.quantitative.pheno --all-pheno --covar Exercise.covar --adjust --out Exercise.filter.linear.adjusted.sort
```
Same as we just did but with the addition of `covar`

#### comparison of most significant SNP
Both models have rs10489401 as the most significant SNPs. As expected, the p-values after multiple testing corrections are much higher (more conservative) than the raw p-values. The p-values are also higher in the model adjusted for age and sex covariates. 

**Linear unadjusted model most significant SNP**
rs12032798: p-value after Bonferroni corrections = 0.03431
```
[USERNAME@login-e molec_w3]$ head -n 2 Exercise.filter.linear.sort.P1.assoc.linear.adjusted
 CHR         SNP      UNADJ         GC       BONF       HOLM   SIDAK_SS   SIDAK_SD     FDR_BH     FDR_BY
   1  rs12032798  5.157e-07  5.755e-07    0.03431    0.03431    0.03373    0.03373    0.03431     0.4009 
```
**Linear adjusted model (age, sex) most significant SNP**
rs12032798: p-value after Bonferroni corrections = 0.03951
```
[USERNAME@login-e molec_w3]$ head -n 2 Exercise.filter.linear.adjusted.sort.P1.assoc.linear.adjusted
 CHR         SNP      UNADJ         GC       BONF       HOLM   SIDAK_SS   SIDAK_SD     FDR_BH     FDR_BY
   1  rs12032798  5.937e-07  6.745e-07    0.03951    0.03951    0.03874    0.03874    0.03951     0.4616 
```

## [11] Compare the beta estimate for rs10495085 in the adjusted and unadjusted GWAS.
For this question, we are to create two new linear regression models
1. Linear model with rs10495085 as the _only_ exposure and the mysterious quantitative measure phenotype as the outcome
2. Linear model with rs10495085 as the main exposure, age & sex as covariates, and the quantitative outcome
We want to compare the beta estimates for these two models. 
> **sidenote:** I think `adjust` is not strictly necessary for comparing beta estimates, but if you want to compare p-values between the two models after corrections for multiple testing, consult the `.adjust` files like we did in [[10]](#comparison-of-most-significant-snp). 

* Create a text file containing the rsID of the SNP of interest. We need to do this because the `--extract` parameter we used in [5] & [6] takes a `.txt` file where each line is a genetic variant as input.
  * these all achieve the same thing, option 1 is just faster
  * option 1: `echo rs10495085 > mySNP.txt`
  * option 2: use a command line text editor `nano mySNP.txt` to create a blank new text file and paste the rsID
  * option 3: use a text editor with a graphical user interface on your local machine (like Notepad or VSCode or some other IDE) to create a new text file `mySNP.txt` and copy it to the HPC server with `scp` like in [[1] Copy data files to HPC server](#1-copy-data-files-to-hpc-server)
* We will tell PLINK to use the genetic variants we care about, which we stored in this file, using `--extract mySNP.txt`.
* Create "unadjusted" (no covariates) linear model
  ```
  plink --bfile Exercise.filter --extract mySNP.txt --linear --pheno Exercise.quantitative.pheno --all-pheno --adjust --out Exercise.filter.linear.sort.mySNP
  ```
* Create "adjusted" (+ age and sex covariates) linear model using `covar` like we did in [9]
  ```
  plink --bfile Exercise.filter --extract mySNP.txt --linear --pheno Exercise.quantitative.pheno --all-pheno --covar Exercise.covar --adjust --out Exercise.filter.linear.adjusted.sort.mySNP
  ```
* Compare beta estimates:
  ```
  [USERNAME@login-c molec_w3]$ head Exercise.filter.linear.sort.mySNP.P1.assoc.linear
  CHR          SNP         BP   A1       TEST    NMISS       BETA         STAT            P 
    1   rs10495085       5838    1        ADD       83      122.7        4.395    3.332e-05
  [USERNAME@login-c molec_w3]$ head Exercise.filter.linear.adjusted.sort.mySNP.P1.assoc.linear
  CHR          SNP         BP   A1       TEST    NMISS       BETA         STAT            P 
    1   rs10495085       5838    1        ADD       83      128.8         4.43    2.993e-05
    1   rs10495085       5838    1       COV1       83      6.702       0.7446       0.4587
    1   rs10495085       5838    1       COV2       83     -0.256      -0.4857       0.6285
  ```
  * beta estimate is higher after adjusting for sex (`COV1`) and age (`COV2`) 
  * beta estimate is also much higher than any of the models we previously created in [8]-[10]. 
  Betas generated by the multiple-SNP analysis we did earlier will have a "dilution effect", where the effect size indicated by beta/odds ratio tends to be small since a constellation of SNPs are contributing to the outcome variable. This is the case when comparing GWAS to candidate-gene association analysis.

> **sidenote**: I initially thought this question was asking to compare the beta estimates for this SNP in the models from [10] but this SNP is not in either model (probably not significant compared to other SNPs). Just FYI, you can search for a specific rsID in the linear/logistic regression reports like this:
> * option 1: using `nano Exercise.filter.linear.sort.P1.assoc.linear` and Ctrl+W to search for the rsID
> * option 2: automatically find the line containing the rsID directly from your command line using `grep 'rs10495085' Exercise.filter.linear.sort.P1.assoc.linear` (found this command on [stackoverflow](https://stackoverflow.com/questions/11797730/how-to-find-lines-containing-a-string-in-linux))

## [12] Which SNP has the smallest number of valid observations in linear GWAS?
```
max_nmiss=$(awk 'NR > 1 {if ($6 > max) max = $6} END {print max}' Exercise.filter.linear.P1.assoc.linear)
awk -v max="$max_nmiss" '$6 == max' Exercise.filter.linear.P1.assoc.linear> max_nmiss_snps.txt
```
This creates a text file `max_nmiss_snps.txt` with information on the 51552 SNPs missing 89 values for linear GWAS (no covariate adjustements) on the filtered dataset. 
> **sidenote:** I counted the number of SNPs using `wc -l max_nmiss_snps.txt` to count the number of lines in the file

## DONE
Congrats for making it to the end! :tada: It is good practice to close your connection with the HPC server using the `exit` command. It is also good practice to take a break :)

## Optional: copy all output files from the HPC server to your local machine
Return to the command line window from [[1] Copy data files to HPC server](#1-copy-data-files-to-hpc-server). Alternatively, open a new command line window and use `cd` to navigate to wherever you want your files saved.

```
scp USERNAME@login.hpc.imperial.ac.uk:'molec_w3/*' .
```
* remember to replace your username
* using inverted commas and `*` to get _any_ files in the molec_w3 folder on the HPC server
* using `.` to specify this current directory as the destination where the files should be copied