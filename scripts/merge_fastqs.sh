

# Assign arguments to variables
FASTQ_DIR=$1  # Directory containing the fastq.gz files
MERGE_FASTQ=$2  # Output directory for merged files
FASTQC_DIR=$3      # Directory to store FastQC reports
CUTADAPT_DIR=$4    # Directory to store trimmed files

# Extract unique sample names (before .1s_sRNA.fastq.gz or .2s_sRNA.fastq.gz)
# And merge samples with same name into a merged.fastq.gz

# Extract unique sample names (before .1s_sRNA.fastq.gz or .2s_sRNA.fastq.gz)
for sample_id in $(ls "$FASTQ_DIR"/*.fastq.gz | awk -F'/' '{print $NF}' | \
sed -E 's/\.[12]s_sRNA.fastq.gz//' | sort -u); 
do
    FILE1="$FASTQ_DIR/${sample_id}.1s_sRNA.fastq.gz"
    FILE2="$FASTQ_DIR/${sample_id}.2s_sRNA.fastq.gz"
    MERGED="$MERGE_FASTQ/${sample_id}_merged.fastq.gz"
    TRIMMED_OUTPUT="$CUTADAPT_DIR/${sample_id}_trimmed.fastq.gz"
    LOG_FILE="$WD/log/cutadapt/${sample_id}_cutadapt.log"

    if [[ -f "$FILE1" && -f "$FILE2" ]]; then
        echo "Merging files for sample: $sample_id"
        cat "$FILE1" "$FILE2" > "$MERGED"
        echo "Created merged file: $MERGED"


    # Run FastQC on the merged file
        echo "Running FastQC on: $MERGED"
        fastqc "$MERGED" -o "$FASTQC_DIR"
        
        # Run Cutadapt to trim adapters from the merged file Adapters (3' Ilumina universal adapters here )
        cutadapt \
        -m 18 \
        -a TGGAATTCTCGGGTGCCAAGG  \
        -o "$TRIMMED_OUTPUT" \
        "$MERGED" > "$LOG_FILE"
        
        echo "Created trimmed file: $TRIMMED_OUTPUT"
    else
        echo "Skipping $sample_id: one or both input files are missing"
        [[ ! -f "$FILE1" ]] && echo "   Missing: $READ1"
        [[ ! -f "$FILE2" ]] && echo "   Missing: $READ2"
    fi
done