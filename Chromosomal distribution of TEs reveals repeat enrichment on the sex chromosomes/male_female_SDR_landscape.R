# Male and female SDR landscapes in one plot 
# Select the sex chromosome and the SDR region from the RepeatMasker output

# Male SDR landscape
DATA1 = fread(file = "male_chr13.out", header = F, stringsAsFactors = F, skip = 3, fill = T)
DATA1 = subset(DATA1, V6 > 2215000 & V7 < 3158000)
DATA1$sex <- "mSDR"

# Female SDR landscape
DATA2 = fread(file = "female_chr13.out", header = F, stringsAsFactors = F, skip = 3, fill = T)
DATA2 = subset(DATA2, V6 > 2173917 & V7 < 3724969)
DATA2$sex <- "fSDR"

DATA <- rbind(DATA1, DATA2)

DATA = DATA[,c("V5","V6","V7","V9","V10","V11","V2","V15","sex")]
names(DATA) = c("Scaffold", "Begin", "End", "Strand", "Element", "Family", "Divergence", "ID", "sex")

# add length of the hits
DATA$Length = DATA$End - DATA$Begin + 1

# delete elements with divergence greater than 100 (there could be artefacts sometimes)
DATA = DATA[DATA$Divergence < 100,]

# re-order the column
DATA = DATA[,c(1:6,10,7,8,9)]

# replace "C" with "-" in the Strand column
DATA$Strand = sub(pattern = "C", replacement = "-", x = DATA$Strand)

#clean up / remove non-TEs

DATA$Family[DATA$Family == "DNA"] <- "DNA/Unknown"
DATA$Family[DATA$Family == "LINE"] <- "LINE/Unknown"
DATA$Family[DATA$Family == "LTR"] <- "LTR/Unknown"
DATA$Family[DATA$Family == "DNA/Helitron"] <- "Helitron"


L2 = DATA[!grepl(pattern = "Simple_repeat", x = DATA$Family),]
L3 = L2[!grepl(pattern = "tandem_repeat", x = L2$Family),]
L4 = L3[!grepl(pattern = "ARTEFACT", x = L3$Family),]
L5 = L4[!grepl(pattern = "rRNA", x = L4$Family),]
L6 = L5[!grepl(pattern = "Low_complexity", x = L5$Family),]
L7 = L6[!grepl(pattern = "snRNA", x = L6$Family),]
L8 = L7[!grepl(pattern = "rDNA", x = L7$Family),]
L2 = L8

L2 <- L2 %>%
  group_by(sex)

# round the divergence values
#DNA$Divergence = DNA$Divergence * 100
L2$RoundDiv = floor(L2$Divergence)

# create a factor with the name of the subfamily/element and the divergence associated to it
# so we can get the number of bps associated to that particular subfamily at that particular divergence
L2$Factor = paste(L2$Element, L2$RoundDiv, sep = "$")
L2$Factor = paste(L2$Family, L2$RoundDiv, sep = "$")
# general landscape - bps occupied
L2_bps = aggregate(Length ~ Factor + sex, L2, sum)
L2_bps$Element = sapply(strsplit(L2_bps$Factor, "\\$"), "[[", 1)
L2_bps$Divergence = sapply(strsplit(L2_bps$Factor, "\\$"), "[[", 2)

# conversion in megabases
#L2_bps$Mb = (L2_bps$Length / 113900589 ) *100 #if you want % you can change the division to the genome length
L2_bps$Mb = (L2_bps$Length / 1000000 )

# assign colors to the subfamilies
coll2 = character()

colfunc <- colorRampPalette(c("#FF1493", "mediumpurple3"))
coll2 = c(coll2, colfunc(9))

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

L2s_plot = ggplot(data = L2_bps, aes(x = as.integer(Divergence), y = Mb, fill = factor(Element))) + geom_bar(stat = "identity") + scale_fill_manual(name = "subclass/superfamily", values = as.character(coll2)) + theme_bw() + xlab("Divergence from consensus (%)") + ylab("TE density (Mb)") + facet_wrap(~ sex, nrow = 1, scales = "fixed")

p <- L2s_plot + theme(panel.grid.major.x = element_blank(),panel.grid.minor.x = element_blank())

cowplot::save_plot(filename = "/Users/edinatale/Desktop/TAC_manuscript/V2/10_plots/TE_landscape_m&fSDR.pdf",
                   p,
                   base_height = 6,
                   base_width = 10)