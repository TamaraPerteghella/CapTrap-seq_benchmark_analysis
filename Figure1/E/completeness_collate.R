library(ggplot2)
library(scales)
library(wesanderson)
library(data.table)
library(stringr)
library(dplyr)

args = commandArgs(trailingOnly=TRUE)

cbPalette=c("#a6a6a6","#b3e0ff", "#C453C4","#e5b3e5")
print("Open orginal")
original = fread(args[1], header=F, sep="\t")
print("Open cage")
cage = fread(args[2], header=F, sep="\t")
print("Open polyA")
polyA = fread(args[3], header=F, sep="\t")

colnames(original)[4] = "id"
colnames(original)[10] = "exon"
colnames(polyA)[4] = "id"
colnames(cage)[4] = "id"

if ( file.exists(args[4]) )
{
    print("Open sirvs")
    sirvs = fread(args[4], header=F, sep="\t")
    original$sirvs = original$id %in% sirvs$id
    colnames(sirvs)[4] = "id"
} else {
    original$sirvs = rep(F, nrow(original))
}

original$polyA = original$id %in% polyA$id 
original$cage = original$id %in% cage$id

original$categ = ifelse( original$cage & original$polyA, "cageAndPolyA", ifelse(original$cage & !original$polyA, "cageOnly", ifelse( (!original$cage) & original$polyA, "polyAOnly", "noCageNoPolyA") ) )
original$categ = factor(original$categ, levels=c("noCageNoPolyA", "polyAOnly", "cageAndPolyA", "cageOnly"))
original$spliced = ifelse(original$exon == 1, F, T)

basename = gsub(".bed.gz", "", unlist(sapply(str_split(args[1], "/"), "tail", 1)) )
saveRDS(original, paste0("tmp/", basename, ".categories.rds"))

plot = original %>% group_by(categ) %>% summarize( count = n() )
plot$percent = round(plot$count/sum(plot$count), 3)

details = unlist(str_split(basename, "[_]"))
plot$seqTech = rep(details[1], nrow(plot))
plot$cellFrac = rep(details[3], nrow(plot))
plot$capture = rep(details[2], nrow(plot))
plot$sample = rep(details[4], nrow(plot))
plot$class = rep("All", nrow(plot))

spliced = original[ original$spliced, ] %>% group_by(categ) %>% summarize( count = n() )
spliced$percent = round(spliced$count/sum(spliced$count), 1)
spliced$seqTech = rep(details[1], nrow(spliced))
spliced$cellFrac = rep(details[3], nrow(spliced))
spliced$capture = rep(details[2], nrow(spliced))
spliced$sample = rep(details[4], nrow(spliced))
spliced$class = rep("Spliced", nrow(spliced))

unspliced = original[ !original$spliced, ] %>% group_by(categ) %>% summarize( count = n() )
unspliced$percent = round(unspliced$count/sum(unspliced$count), 1)

unspliced$seqTech = rep(details[1], nrow(unspliced))
unspliced$cellFrac = rep(details[3], nrow(unspliced))
unspliced$capture = rep(details[2], nrow(unspliced))
unspliced$sample = rep(details[4], nrow(unspliced))
unspliced$class = rep("Unpliced", nrow(unspliced))

plot = rbind(plot, spliced, unspliced)
print(paste0(basename, ".count.tsv"))
write.table(plot, paste0(basename, ".count.tsv"), row.names = F, col.names = F, quote = F)
