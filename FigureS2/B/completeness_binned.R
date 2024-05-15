library(ggplot2)
library(purrr)
library(scales)
library(wesanderson)
library(dplyr)
library(data.table)

args = commandArgs(trailingOnly=TRUE)
cbPalette=c("#a6a6a6","#b3e0ff","#C453C4","#e5b3e5")

lengths = fread("../../Figure1/D/benchmark.readlength.collate.tsv")
colnames(lengths) = c("id","platform","capture","frac","sample","length")

files = list.files("../../Figure1/E/tmp/", full.names = T) %>% map_dfr(readRDS)
data = merge(files, lengths, by="id")

bins = seq(0, 3000, by = 200)
data$binned = cut(as.numeric(data$length), breaks=bins,include.lowest=T)

data = data %>%
  filter( !sirvs & !is.na(data$length)) %>%
  mutate(sample=ifelse(sample=="Brain01Rep1", paste0("Brain"), sample)) %>% 
  mutate(sample=ifelse(sample=="Brain03Rep1", paste0("Brain"), sample)) %>% 
  mutate(sample=ifelse(sample=="Brain01Rep3", paste0("Brain"), sample))

print("Data Sliced")
saveRDS(data, "HpreCap.sliced.rds")
# Fix notation from scientific to normal
fix_notation <- function(x) {
  if (is.na(x)) {
    return(x)
  }
  
  x <- as.character(x) 
  start <- substr(x, start = 1, stop=1)
  end <- substr(x, start=nchar(x), stop=nchar(x))
  
  n1 <- strsplit(x, split=",")[[1]][1] %>%
    substr(start=2, stop=nchar(.)) %>% 
    as.numeric(.)
  
  n2 <- strsplit(x, split=",")[[1]][2] %>%
    substr(start=1, stop=nchar(.)-1) %>% 
    as.numeric(.)
  
  return(paste0(start, n1, ",", n2, end))
}

# Apply function
data %>% 
  rowwise() %>% 
  mutate(binned=ifelse(is.na(binned), paste0(">3000"), fix_notation(binned))) %>% 
  mutate(binned=ifelse(binned=="[0,200]", paste0("(0,200]"), binned)) -> data

print("Notation Fixed")
saveRDS(data, "HpreCap.fixed.rds")

data$categ = factor(data$categ, levels=c("noCageNoPolyA", "polyAOnly", "cageAndPolyA", "cageOnly"))
data$platform = factor(data$platform, levels=c("ont-Crg-CapTrap", "ont-Crg-dRNA", "ont-Crg-Telop", "ont-Cshl-Smarter"))

ggplot(data=data, aes(x=factor(binned, levels=c("(0,200]", "(200,400]", "(400,600]",
                                                "(600,800]", "(800,1000]", "(1000,1200]",
                                                "(1200,1400]", "(1400,1600]",
                                                "(1600,1800]", "(1800,2000]",
                                                "(2000,2200]", "(2200,2400]",
                                                "(2400,2600]", "(2600,2800]",
                                                "(2800,3000]", ">3000")), fill=categ)) +
  geom_bar(position = "fill") +
  scale_y_continuous(limits=c(0,1.05), labels=percent) +
  ylab("Proportion of reads") +
  theme_bw() +
  #ggtitle("HpreCap") +
  scale_fill_manual(values=cbPalette) +
  xlab("") +
  theme(axis.text.x = element_text(size = 12, colour = "black", vjust=0.5, angle = 90, hjust=1),
        axis.text.y = element_text(size = 12, colour = "black", vjust=0.5),
        legend.text = element_text(size= 14),
        plot.title = element_text(size = 14),
        legend.title = element_text(size= 0, color="white"),
        axis.title.x = element_text(size = 14),
        axis.title.y = element_text(size = 14),
        legend.text.align=0.5,
        strip.text.x=element_text(size=14), strip.text.y=element_text(size=14)) +
  theme(legend.position="top") +
  facet_grid(sample ~ platform, scales="free_x") 
