# Reformat json and save dumux stats
library(jsonlite)
library(reshape2)
library(tidyverse)

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
stats_json_path <- "../demux_stats/Stats.json"

js <- jsonlite::read_json(stats_json_path, simplifyVector = TRUE)
lane_data <- collapse_demux_results(js$ConversionResults$DemuxResults)
lane_data$Lane <- factor(lane_data$Lane)
known_barcodes <- lane_data[,c('Lane', 'SampleId', 'NumberReads')]

# Parse unknown barcodes
unknown_barcodes <- js$UnknownBarcodes$Barcodes
unknown_barcodes$Lane <- factor(row.names(unknown_barcodes))
unknown_barcodes <- melt(unknown_barcodes, variable.name = 'Barcode', 
                         value.name = 'NumberReads')

# Sum up the PhiX reads from the unknowns
PhiX_by_lane <- unknown_barcodes[unknown_barcodes$Barcode == "GGGGGGGG",]
PhiX_by_lane$SampleId <- "PhiX"
total_PhiX <- sum(PhiX_by_lane$NumberReads)

# Generate final data-frames
bind_rows(known_barcodes, PhiX_by_lane)


