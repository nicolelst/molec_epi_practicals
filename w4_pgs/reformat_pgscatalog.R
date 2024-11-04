data <- read.csv("PGS000298_hmPOS_GRCh37.txt", skip = 19,sep = "\t", header = TRUE)

data <- data[c("rsID", "effect_allele", "effect_weight")]

write.table(data, "score_file_bmi.txt", sep="\t", quote = FALSE, row.names=FALSE, col.names=FALSE)