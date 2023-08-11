## run_bcl2fastq.sh
Demultiplex illumina runs using bcl2fastq on HMS O2

### Requires: 

Written to run on HMS O2 cluster.

- bcl2fastq (currently uses version 2.20.0.422)


## demux_stats_plots
Create plots for Illumina bcl2fastq Stats.json

### Requires: 

R (I have only tested v3.2.1, but suspect it will work with many others) with
the following packages:
 
- jsonlite
- reshape2
- ggplot2

### Usage:

```
Rscript demux_plots.R </path/to/Stats.json>
```

Will generate three PDFs in your current directory:

```
<Flowcell ID>_demultiplex_by_lane.pdf
<Flowcell ID>_demultiplex.pdf
<Flowcell ID>_unknown_barcodes.pdf
```
