#!/usr/bin/env nextflow
input_list = params.input?.tokenize(',')
params.cutoff="${input_list[1]}"

process filterExp {
 input:
 path expData
 val cutoff
 output:
 path "expression_filtered_2.txt"
 script:
 """
 #!/usr/bin/env Rscript
 data<-read.table("$expData", as.is=TRUE, header=TRUE, sep='\\t', row.names=1)
 data_filt<-data[which(rowMeans(data) >= $cutoff),]
 write.table(data_filt,"expression_filtered_2.txt", sep='\\t')
 """
}
process boxplot {
 input:
 path expData
 output:
 path "boxplot_2.pdf"
 script:
 """
 #!/usr/bin/env Rscript
 data_filt<-read.table("$expData", as.is=TRUE, header=TRUE, sep='\\t', row.names=1)
 pdf("boxplot_2.pdf")
 par(mar = c(10, 4, 2, 2))
 boxplot(data_filt,las=2)
 dev.off()
 """
}
workflow {
 inputFile=Channel.fromPath("${input_list[0]}")
 filteredData=filterExp(inputFile,params.cutoff)
 boxplot(filteredData)
}
