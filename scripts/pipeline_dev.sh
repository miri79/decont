export WD=$(pwd)

#Create a directories to store the fastq and contaminants fasta
mkdir -p "$WD/data/fastq"
mkdir -p "$WD/res/ref"
mkdir -p "$WD/data/fastq/merge_fastq"
mkdir -p "$WD/out/fastqc"
mkdir -p "$WD/out/cutadapt"
mkdir -p "$WD/log/cutadapt"
mkdir -p "$WD/res/ref/star_index"

#Define directories
DATA_DIR="$WD/data"
FASTQ_DIR="$WD/data/fastq"
URL_FILE="$WD/data/urls"
MERGE_FASTQ="$WD/data/fastq/merge_fastq"


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

awk '
    /^>/ {
        keep = ($0 !~ /small nuclear RNA/)
    }
    keep
' "$WD/res/ref/contaminants.fasta" > "$WD/res/ref/filtered_contaminants.fasta"


#Call the download script 
bash scripts/download.sh "$URL_FILE" "$FASTQ_DIR" "$UNCOMPRESS"

#Merge the samples into a single file

bash scripts/merge_fastqs.sh "$DATA_DIR" "$MERGE_FASTQ" 

# FastQC analysis index and alignment

#for sampleid in $(ls data/*fastq.gz|cut -d_ -f1|cut -d/ -f2|sort|uniq) 
#do bash $WD/scripts/quality_cutadpat_indexv1.sh "$sampleid"





