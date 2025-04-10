
# Arguments
CUTADAPT_DIR=$1    # Directory to store trimmed files
INDEX_DIR=$2       # STAR index directory
ALIGN_DIR=$3       # Directory to store STAR output
MERGE_FASTQ=$4     # Path to directory with merged fastq files


# Loop through merged files
for fname in "$MERGE_FASTQ"/*_merged.fastq.gz; do
    # Extract sample ID
    sid=$(basename "$fname" | sed 's/_merged.fastq.gz//')

    LOG_FILE="$WD/log/${sid}_alignment.log"
    echo "Log started for $sid at $(date)" >> "$LOG_FILE"
    echo "===================" >> "$LOG_FILE"

    # Paths
    MERGED="$fname"
    TRIMMED_OUTPUT="$CUTADAPT_DIR/${sid}_trimmed.fastq.gz"
    CUTADAPT_LOG="$WD/log/cutadapt/${sid}_cutadapt.log"
    STAR_LOG="$ALIGN_DIR/${sid}/Log.final.out"

    # Create STAR output and log dir
    mkdir -p "$ALIGN_DIR/$sid"
    mkdir -p "$WD/log/star/$sid"
    # Run Cutadapt
    echo "Running Cutadapt for $sid" >> "$LOG_FILE"
    cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed \
        -o "$TRIMMED_OUTPUT" "$MERGED" >> "$CUTADAPT_LOG" 2>&1

    echo "Cutadapt results for $sid:" >> "$LOG_FILE"
    grep -E "Reads with adapters|Total basepairs" "$CUTADAPT_LOG" >> "$LOG_FILE"

    # Run STAR Including outSAMunmapped, the unmapped reads will be included in the Aligned.out.sam
    #The unmapped (not contaminant sequenced are in the Unmapped.out.mate1 file of each sample)
    echo "Running STAR for $sid" >> "$LOG_FILE"
    STAR --runThreadN 4 \
         --genomeDir "$INDEX_DIR" \
         --outReadsUnmapped Fastx \
         --readFilesIn "$TRIMMED_OUTPUT" \
         --readFilesCommand "gunzip -c" \
         --outSAMunmapped Within \
         --outFileNamePrefix "$ALIGN_DIR/$sid/" >> "$STAR_LOG" 2>&1

    echo "STAR results for $sid:" >> "$LOG_FILE"
    grep -E "Number of input reads|Uniquely mapped reads %|% of reads mapped to multiple loci|% of reads mapped to too many loci|% of reads unmapped" "$STAR_LOG" >> "$LOG_FILE"

done
