#!/bin/bash
#SBATCH -c 12                                   # Number of cores requested
#SBATCH -t 0-03:00                              # Walltime HH:MM
#SBATCH -p priority                             # Partition requested
#SBATCH --mem=32G                               # RAM requested
#SBATCH -o run_bcl2fastq_%j.out                 # Std-out file name
#SBATCH -e run_bcl2fastq_%j.err                 # Error file name
#SBATCH --mail-type=ALL                         # ALL email notification types
#SBATCH --mail-user=email@me.com # Email for notifications


############################################################################
# Load required modules
module load bcl2fastq/2.20.0.422

############################################################################
# Job-specific vaiables
PROJECT_DIR="/path/to/project"
BCL_DIR="${PROJECT_DIR}/bcl"
SAMPLE_SHEET="${BCL_DIR}/SampleSheet.csv"
############################################################################
# Run bcl2fastq
mkdir -p ${PROJECT_DIR}/demux_stats
mkdir -p ${PROJECT_DIR}/fastq \

# record start time for metadata
START_TIME=$(date)

bcl2fastq \
        --sample-sheet ${SAMPLE_SHEET} \
        --ignore-missing-bcls \
        --ignore-missing-filter \
        --ignore-missing-positions \
        --mask-short-adapter-reads 0 \
        --minimum-trimmed-read-length 1 \
        --no-lane-splitting \
        --runfolder-dir ${BCL_DIR} \
        --stats-dir ${PROJECT_DIR}/demux_stats \
        --output-dir ${PROJECT_DIR}/fastq \
        --loading-threads=$((SLURM_JOB_CPUS_PER_NODE/4)) \
        --writing-threads=$((SLURM_JOB_CPUS_PER_NODE/4)) \
        --processing-threads=${SLURM_JOB_CPUS_PER_NODE} \
        --fastq-compression-level=9

# record end time for metadata
END_TIME=$(date)

echo "Job started: ${START_TIME}"
echo "Job ended: ${END_TIME}"
