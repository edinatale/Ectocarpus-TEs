# libraries required
library(data.table)
library(dplyr)
library(ggplot2)
library(RColorBrewer)

#Landscape Ectocarpus genome
DATA = fread(file = "../01_RM_OneCode/V5.fasta.out", header = F, stringsAsFactors = F, skip = 3, fill = T)

DATA = DATA[,c(5,6,7,9,10,11,2,15)]
names(DATA) = c("Scaffold", "Begin", "End", "Strand", "Element", "Family", "Divergence", "ID")

# add length of the hits
DATA$Length = DATA$End - DATA$Begin + 1

# delete elements with divergence greater than 100 (there could be artefacts sometimes)
DATA = DATA[DATA$Divergence < 100,]

# re-order the column
DATA = DATA[,c(1:6,9,7,8)]

# replace "C" with "-" in the Strand column
DATA$Strand = sub(pattern = "C", replacement = "-", x = DATA$Strand)

#clean up / remove non-TEs
DATA$Family[DATA$Family == "DNA"] <- "DNA/Unknown"
DATA$Family[DATA$Family == "LINE"] <- "LINE/Unknown"
DATA$Family[DATA$Family == "LTR"] <- "LTR/Unknown"


L2 = DATA[!grepl(pattern = "Simple_repeat", x = DATA$Family),]
L3 = L2[!grepl(pattern = "tandem_repeat", x = L2$Family),]
L4 = L3[!grepl(pattern = "ARTEFACT", x = L3$Family),]
L5 = L4[!grepl(pattern = "rRNA", x = L4$Family),]
L6 = L5[!grepl(pattern = "Low_complexity", x = L5$Family),]
L7 = L6[!grepl(pattern = "snRNA", x = L6$Family),]
L8 = L7[!grepl(pattern = "rDNA", x = L7$Family),]
L2 = L8

# round the divergence values
#DNA$Divergence = DNA$Divergence * 100
L2$RoundDiv = floor(L2$Divergence)

# create a factor with the name of the subfamily/element and the divergence associated to it
# so we can get the number of bps associated to that particular subfamily at that particular divergence
L2$Factor = paste(L2$Element, L2$RoundDiv, sep = "$")
L2$Factor = paste(L2$Family, L2$RoundDiv, sep = "$")
# general landscape - bps occupied
L2_bps = aggregate(Length ~ Factor, L2, sum)
L2_bps$Element = sapply(strsplit(L2_bps$Factor, "\\$"), "[[", 1)
L2_bps$Divergence = sapply(strsplit(L2_bps$Factor, "\\$"), "[[", 2)

# conversion in megabases
#L2_bps$Mb = (L2_bps$Length / 113900589 ) *100 #if you want % you can change the division to the genome length
L2_bps$Mb = (L2_bps$Length / 1000000 )

# assign colors to the subfamilies
coll2 = character()

colfunc <- colorRampPalette(c("#FF1493", "mediumpurple3"))
coll2 = c(coll2, colfunc(11))

colfunc <- colorRampPalette(c("tomato3", "tomato3"))
coll2 = c(coll2, colfunc(1))

colfunc <- colorRampPalette(c("#87CEEB", "#4169E1"))
coll2 = c(coll2, colfunc(4))

colfunc <- colorRampPalette(c("#FFDAB9", "#FFA500"))
coll2 = c(coll2, colfunc(3))

colfunc <- colorRampPalette(c("palegreen3", "seagreen"))
coll2 = c(coll2, colfunc(2))

colfunc <- colorRampPalette(c("brown", "brown"))
coll2 = c(coll2, colfunc(1))

colfunc <- colorRampPalette(c("#999999", "#999999"))
coll2 = c(coll2, colfunc(1))

L2_bps$Element  <- factor(L2_bps$Element , levels = c("DNA/Unknown", "DNA/Dada", "DNA/Harbinger", "DNA/hAT", "DNA/KDZ", "DNA/Plavaka", "DNA/MuDR", "DNA/PiggyBac", "DNA/Mariner-Tc1", "DNA/Sola-1", "DNA/Sola-2", "Helitron", "LINE/Unknown", "LINE/RTE", "LINE/RTE-X", "LINE/CRE", "LTR/Unknown", "LTR/Copia", "LTR/Gypsy", "DIRS/PAT-like", "DIRS/Ngaro", "PLE/Chlamys", "Unknown"))
L2_bps[order(L2_bps$Element), ]

L2s_plot = ggplot(data = L2_bps, aes(x = as.integer(Divergence), y = Mb, fill = factor(Element))) + geom_bar(stat = "identity") + scale_fill_manual(name = "subclass/superfamily", values = as.character(coll2)) + theme_bw() + xlab("Divergence from consensus (%)") + ylab("TE density (Mb)")

p <- L2s_plot + theme(panel.grid.major.x = element_blank(),panel.grid.minor.x = element_blank())

cowplot::save_plot(filename = "/Users/edinatale/Desktop/TAC_manuscript/V2/10_plots/TE_landscape2.pdf",
                   p,
                   base_height = 6,
                   base_width = 10)