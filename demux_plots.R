# Demultiplexing plots for Illumina bcl2fastq >= 2.18 Stats.json
# Usage:
# Rscript DemultiplexingPlots.R [/path/to/Stats.json]

library(jsonlite)
library(reshape2)
library(ggplot2)

args <- commandArgs(trailingOnly = TRUE)


# Given an index (i) and list of data frames (l), return ith data
# frame with a new column (Lane)
add_lane_to_df <- function(i, l){
  df <- l[[i]]
  df$Lane <- i
  return(df)
}

# Given a list of data frames (l), combines all rows by adding their
# list index number to column "Lane". Works with add_lane_to_df to
# collapse the DemuxResults to a single data frame with one row
# per sample.
collapse_demux_results <- function(l){
  #l <- js$ConversionResults$DemuxResults
  res <- lapply(seq_along(l), add_lane_to_df, l=l)
  df <- do.call("rbind", res)
  return(df)
}

# Parse known barcodes
stats_json_path <- args[1]
#stats_json_path <- '~/pnap_home/Stats.json'

js <- jsonlite::read_json(stats_json_path, simplifyVector = TRUE)
lane_data <- collapse_demux_results(js$ConversionResults$DemuxResults)
lane_data$Lane <- factor(lane_data$Lane)
known_barcodes <- lane_data[,c('Lane', 'SampleId', 'NumberReads')]


# Parse unknown barcodes
unknown_barcodes <- js$UnknownBarcodes$Barcodes
unknown_barcodes$Lane <- factor(row.names(unknown_barcodes))
unknown_barcodes <- melt(unknown_barcodes, variable.name = 'Barcode', value.name = 'NumberReads')


# Save the known barcode plot
p <- ggplot(known_barcodes, aes(SampleId, NumberReads, fill=SampleId))+
  geom_bar(stat = 'identity')+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))+
  ggtitle(paste0(js['Flowcell']))+
  guides(fill = FALSE)
ggsave(filename = paste0(js['Flowcell'], '_demultiplex.pdf'), plot=p)


# Save the unknown barcode plot
# This is pretty ugly, but it works for now...
p <- ggplot(unknown_barcodes, aes(Lane, NumberReads, label=Barcode))+
  geom_bar(position = 'stack', stat = 'identity', color='black')+
  geom_text(size = 3, position = position_stack(vjust = 0.5))+
  ggtitle(paste0(js['Flowcell']))+
  guides(fill = FALSE)
ggsave(filename = paste0(js['Flowcell'], '_unknown_barcodes.pdf'), plot=p)


# Overall Lane Plot
# Collapse unknown barcodes
uk <- data.frame(NumberReads=rowSums(js$UnknownBarcodes$Barcodes, na.rm = TRUE))
uk$Lane <- factor(row.names(uk))
# Now plot!
p <- ggplot(known_barcodes, aes(Lane, NumberReads, fill=SampleId))+
  geom_bar(position = 'stack', stat = 'identity')+
  geom_bar(data=uk,
           aes(Lane, NumberReads),
           stat = 'identity',
           fill='#626567')+
  ggtitle(paste0(js['Flowcell']))+
  guides(fill=FALSE)
ggsave(filename = paste0(js['Flowcell'], '_demultiplex_by_lane.pdf'), plot=p)
