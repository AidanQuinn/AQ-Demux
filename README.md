# demux_stats_plots
Create plots for Illumina bcl2fastq Stats.json

# Requires: 

R (I have only tested v3.2.1, but suspect it will work with many others) with
the following packages:
 
- jsonlite
- reshape2
- ggplot2

# Usage:

```
demux_plots.R </path/to/Stats.json>
```

Will generate three PDFs in your current directory:

```
<Flowcell ID>_demultiplex_by_lane.pdf
<Flowcell ID>_demultiplex.pdf
<Flowcell ID>_unknown_barcodes.pdf
```
