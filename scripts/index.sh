# This script should index the genome file specified in the first argument ($1),
# creating the index in a directory specified by the second argument ($2).

# The STAR command is provided for you. You should replace the parts surrounded
# by "<>" and uncomment it.

GENOME_FILE=$1       
INDEX_DIR=$2   

for fname in out/cutadapt/*.fastq.gz
do
    STAR --runThreadN 4 --runMode genomeGenerate --genomeDir $INDEX_DIR \
    --genomeFastaFiles $GENOME_FILE --genomeSAindexNbases 9
done 


