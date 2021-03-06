source("epidish.R")


ref.m <- as.matrix(read.csv("LM22_cibersort_immune_signature.txt", header=T, row.names=1, sep="\t", check.names=F))
data.m <- as.matrix(read.csv("All90.HTSeq.rpkm.xls", header=T, row.names=1, sep="\t", check.names=F))

maxit <- 50
nu.v <- c(0.25,0.5,0.75)

celltype.o <- DoCBS(data.m, ref.m, nu.v);

cellFrac.m <- t(t(celltype.o$estF))


cellFracCom.m <- matrix(NA, ncol=11, nrow=nrow(cellFrac.m))
colnames(cellFracCom.m) <- c("T_cells_CD8", "T_cells_CD4_naive", "T_cells_CD4_memory_resting", "T_cells_CD4_memory_activated", "T_cells_Follicular_helper", "T_cells_regulatory", "T_cells_gamma_delta", "NK_cells_resting",  "NK_cells_activated", "Dendritic_cells_resting",  "Dendritic_cells_activated")
rownames(cellFracCom.m) <- rownames(cellFrac.m )


T_cells_CD8.idx <- c(4)
T_cells_CD4_naive.idx <- c(5)
T_cells_CD4_memory_resting.idx <- c(6)
T_cells_CD4_memory_activated.idx <- c(7)
T_cells_Follicular_helper.idx <- c(8)
T_cells_regulatory.idx <- c(9)
T_cells_gamma_delta.idx <- c(10)
NK_cells_resting.idx <- c(11)
NK_cells_activated.idx <- c(12)
Dendritic_cells_resting.idx <- c(17)
Dendritic_cells_activated.idx <- c(18)

cellFracCom.m[,1] <- cellFrac.m[,T_cells_CD8.idx]
cellFracCom.m[,2] <- cellFrac.m[,T_cells_CD4_naive.idx]
cellFracCom.m[,3] <- cellFrac.m[,T_cells_CD4_memory_resting.idx]
cellFracCom.m[,4] <- cellFrac.m[,T_cells_CD4_memory_activated.idx]
cellFracCom.m[,5] <- cellFrac.m[,T_cells_Follicular_helper.idx]
cellFracCom.m[,6] <- cellFrac.m[,T_cells_regulatory.idx]
cellFracCom.m[,7] <- cellFrac.m[,T_cells_gamma_delta.idx]
cellFracCom.m[,8] <- cellFrac.m[,NK_cells_resting.idx]
cellFracCom.m[,9] <- cellFrac.m[,NK_cells_activated.idx]
cellFracCom.m[,10] <- cellFrac.m[,Dendritic_cells_resting.idx]
cellFracCom.m[,11] <- cellFrac.m[,Dendritic_cells_activated.idx]


cellFracCom.m <- cellFracCom.m * 100

PhenoTypes.df <- read.csv("SampleClass.txt", header=F, sep="\t")
tmp.idx <- match(rownames(cellFracCom.m), PhenoTypes.df[,1])
PhenoTypes.df <- PhenoTypes.df[tmp.idx,]

cancer.idx <- which(PhenoTypes.df$V2 == "cancer")
cellFracCom.m <- cellFracCom.m[cancer.idx,]
data.m <- data.m[,cancer.idx]
############

cellFracCom.df <- as.data.frame(cellFracCom.m)
cellFracCom.df$Index <- NA

BCL9.idx <- which(rownames(data.m) == "BCL9")
BCL9.v <- data.m[BCL9.idx,]
#fivenum(BCL9.v)
quantile(BCL9.v)
cellFracCom.df$Index[which(BCL9.v <= quantile(BCL9.v)[2] )] <- "Bottom"
cellFracCom.df$Index[which(BCL9.v >= quantile(BCL9.v)[4] )] <- "Top"

library(reshape2)
library(ggplot2)
library(ggpubr)
data.df <- melt(cellFracCom.df)
data.df <- data.df[which(!is.na(data.df[,1])),]
ggplot(data.df, aes(x = Index, y=value)) + geom_violin() + facet_wrap(variable ~ . ) + theme_bw()
ggsave("tmp.pdf")
ggviolin(data = data.df ,x='Index',y='value', fill='Index', palette = c("#FC4E07", "#00AFBB"), facet.by = 'variable',add = "boxplot",add.params = list(fill="white"), ggtheme = theme_light(), legend = "", ylab="Cibersort infiltration estimates", xlab="")+ stat_compare_means(comparisons=list(c('Bottom','Top')),label = "p.signif")
ggsave("DATA_results/DATA_subset_BCL9_Cibersort_Plot.pdf")



####### Indivival ####
celltypes.v <- c("T_cells_CD8", "T_cells_CD4_naive", "T_cells_CD4_memory_resting", "T_cells_CD4_memory_activated", "T_cells_Follicular_helper", "T_cells_regulatory", "T_cells_gamma_delta", "NK_cells_resting",  "NK_cells_activated", "Dendritic_cells_resting",  "Dendritic_cells_activated")
for(i in 1:length(celltypes.v )){
tmp.idx <- which(data.df$variable == celltypes.v[i])
tmp.df <- data.df[tmp.idx,]
tmp.df <- within(tmp.df, Index <- factor(Index, levels=c('Bottom','Top')))
p <- ggboxplot(data = tmp.df ,x='Index',y='value', fill='Index', palette = c("blue", "red"), add.params = list(fill="white"), ggtheme = theme_few(), legend = "", ylab="Cibersort score", xlab="") + stat_compare_means()
p <- p + annotate("text", x = 1 , y = -1, label = paste("( n = ", length(which(tmp.df[,1] == "Bottom")), ")") )
p <- p + annotate("text", x = 2 , y = -1, label = paste("( n = ", length(which(tmp.df[,1] == "Top")), ")") )
p
ggsave(paste0("DATA_results/DATA_subset_BCL9/", celltypes.v[i], "_Cibersort_Plot.pdf"), width=4, height=4.5)
}


#############
cellFracCom.df <- as.data.frame(cellFracCom.m)
cellFracCom.df$Index <- NA

BCL9.idx <- which(rownames(data.m) == "BCL9L")
BCL9.v <- data.m[BCL9.idx,]
#fivenum(BCL9.v)
quantile(BCL9.v)
cellFracCom.df$Index[which(BCL9.v <= quantile(BCL9.v)[2] )] <- "Bottom"
cellFracCom.df$Index[which(BCL9.v >= quantile(BCL9.v)[4] )] <- "Top"


data.df <- melt(cellFracCom.df)
data.df <- data.df[which(!is.na(data.df[,1])),]
#ggplot(data.df, aes(x = Index, y=value)) + geom_violin() + facet_wrap(variable ~ . ) + theme_bw()
#ggsave("tmp.pdf")
ggviolin(data = data.df ,x='Index',y='value', fill='Index', palette = c("#FC4E07", "#00AFBB"), facet.by = 'variable',add = "boxplot",add.params = list(fill="white"), ggtheme = theme_light(), legend = "", ylab="Cibersort infiltration estimates", xlab="")+ stat_compare_means(comparisons=list(c('Bottom','Top')),label = "p.signif")
ggsave("DATA_results/DATA_subset_BCL9L_Cibersort_Plot.pdf")



####### Indivival ####
celltypes.v <- c("T_cells_CD8", "T_cells_CD4_naive", "T_cells_CD4_memory_resting", "T_cells_CD4_memory_activated", "T_cells_Follicular_helper", "T_cells_regulatory", "T_cells_gamma_delta", "NK_cells_resting",  "NK_cells_activated", "Dendritic_cells_resting",  "Dendritic_cells_activated")
for(i in 1:length(celltypes.v )){
tmp.idx <- which(data.df$variable == celltypes.v[i])
tmp.df <- data.df[tmp.idx,]
tmp.df <- within(tmp.df, Index <- factor(Index, levels=c('Bottom','Top')))
p <- ggboxplot(data = tmp.df ,x='Index',y='value', fill='Index', palette = c("blue", "red"), add.params = list(fill="white"), ggtheme = theme_few(), legend = "", ylab="Cibersort score", xlab="") + stat_compare_means()
p <- p + annotate("text", x = 1 , y = -1, label = paste("( n = ", length(which(tmp.df[,1] == "Bottom")), ")") )
p <- p + annotate("text", x = 2 , y = -1, label = paste("( n = ", length(which(tmp.df[,1] == "Top")), ")") )
p
ggsave(paste0("DATA_results/DATA_subset_BCL9L/", celltypes.v[i], "_Cibersort_Plot.pdf"), width=4, height=4.5)
}
##################################################################################################

#allmutSample.v <- substr(as.vector(read.csv("Allsamples.txt", header=F,)[,1]), 1, 16)
#CTNNB1_Sample.v <- substr(as.vector(read.csv("CTNNB1_mutated_samples.txt", header=F,)[,1]), 1, 16)

CTNNB1_Sample.v <- c("A1076", "A1099", "LV0042T", "LV0046T", "LV0068T", "LV0069T", "LV0092T", "LV61101T", "T15_422", "T16", "T275")

cellFracCom.df <- as.data.frame(cellFracCom.m)
cellFracCom.df$Index <- "WT"


tmp.idx <- match(rownames(cellFracCom.df), CTNNB1_Sample.v)
cellFracCom.df[which(!is.na(tmp.idx)), 12] <- "MUT"


data.df <- melt(cellFracCom.df)
data.df <- data.df[which(!is.na(data.df[,1])),]
#ggplot(data.df, aes(x = Index, y=value)) + geom_violin() + facet_wrap(variable ~ . ) + theme_bw()
#ggsave("tmp.pdf")
ggviolin(data = data.df ,x='Index',y='value', fill='Index', palette = c("#E7B800", "#3366CC"), facet.by = 'variable',add = "boxplot",add.params = list(fill="white"), ggtheme = theme_light(), legend = "", ylab="Cibersort infiltration estimates", xlab="")+ stat_compare_means(comparisons=list(c('MUT', 'WT')),label = "p.signif")
ggsave("DATA_results/DATA_subset_CTNNB1_mut_Cibersort_Plot.pdf")




####### Indivival ####
celltypes.v <- c("T_cells_CD8", "T_cells_CD4_naive", "T_cells_CD4_memory_resting", "T_cells_CD4_memory_activated", "T_cells_Follicular_helper", "T_cells_regulatory", "T_cells_gamma_delta", "NK_cells_resting",  "NK_cells_activated", "Dendritic_cells_resting",  "Dendritic_cells_activated")
for(i in 1:length(celltypes.v )){
tmp.idx <- which(data.df$variable == celltypes.v[i])
tmp.df <- data.df[tmp.idx,]
tmp.df <- within(tmp.df, Index <- factor(Index, levels=c('WT','MUT')))
p <- ggboxplot(data = tmp.df ,x='Index',y='value', fill='Index', palette = c("blue", "red"), add.params = list(fill="white"), ggtheme = theme_few(), legend = "", ylab="Cibersort score", xlab="") + stat_compare_means()
p <- p + annotate("text", x = 1 , y = -1, label = paste("( n = ", length(which(tmp.df[,1] == "WT")), ")") )
p <- p + annotate("text", x = 2 , y = -1, label = paste("( n = ", length(which(tmp.df[,1] == "MUT")), ")") )
p
ggsave(paste0("DATA_results/DATA_subset_CTNNB1/", celltypes.v[i], "_Cibersort_Plot.pdf"), width=4, height=4.5)
}



