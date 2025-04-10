export WD=$(pwd)

#Create a directories to store the fastq and contaminants fasta
mkdir -p "$WD/data/fastq"
mkdir -p "$WD/res/ref"
mkdir -p "$WD/data/fastq/merge_fastq"
mkdir -p "$WD/out/fastqc"
mkdir -p "$WD/out/cutadapt"
mkdir -p "$WD/log/cutadapt"
mkdir -p "$WD/res/ref/star_index"
mkdir -p "$WD/out/star"
mkdir -p "$WD/log/star"


#Define directories
DATA_DIR="$WD/data"
FASTQ_DIR="$WD/data/fastq"
URL_FILE="$WD/data/urls"
MERGE_FASTQ="$WD/data/fastq/merge_fastq"
FASTQC_DIR="$WD/out/fastqc"
CUTADAPT_DIR="$WD/out/cutadapt"
GENOME_FILE="$WD/res/ref/"
INDEX_DIR="$WD/res/ref/star_index"
ALIGN_DIR="$WD/out/star"

# Ask the user if they want to uncompress
read -p "Do you want to uncompress downloaded files? (yes/no): " UNCOMPRESS

# Ensure input is either "yes" or "no" (default to "no" if empty)
UNCOMPRESS=${UNCOMPRESS:-no}

#Download the contaminant reference 

wget -P "$WD/res/ref"  https://bioinformatics.cnio.es/data/courses/decont/contaminants.fasta.gz
gunzip -f -k $WD/res/ref/contaminants.fasta.gz

# - filter the sequences based on a word contained in their header lines: small nuclear RNA
# It will delete the identified header and the subsequent lines until it finds other >not matching header
#then removes al the headers of the remaining sequences

awk ' /^>/ { keep = ($0 !~ /small nuclear RNA/) } keep' \
"$WD/res/ref/contaminants.fasta" > "$WD/res/ref/filtered_contaminants.fasta"


#Call the download script 
echo "Running: bash scripts/download.sh \"$URL_FILE\" \"$FASTQ_DIR\" \"$UNCOMPRESS\""
bash scripts/download.sh "$URL_FILE" "$FASTQ_DIR" "$UNCOMPRESS"

#Merge the samples into a single file
echo "Running: bash scripts/merge_fastqs.sh \"$FASTQ_DIR\" \"$MERGE_FASTQ\" \"$FASTQC_DIR\" \"$CUTADAPT_DIR\""
bash scripts/merge_fastqs.sh "$FASTQ_DIR" "$MERGE_FASTQ" "$FASTQC_DIR" "$CUTADAPT_DIR"

# TODO: run STAR for all trimmed files

GENOME_FILE="$WD/res/ref/filtered_contaminants.fasta"
# Index the contaminants file
bash scripts/index.sh $GENOME_FILE $INDEX_DIR

#Align the trimmed files with the filtered_contaminant.fasta
bash scripts/align.sh $CUTADAPT_DIR $INDEX_DIR $ALIGN_DIR $MERGE_FASTQ






