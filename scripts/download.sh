# This script  download the file specified in the first argument ($1),
# place it in the directory specified in the second argument ($2),


URL_FILE=$1        # Path to URL list
FASTQ_DIR=$2       # Directory to store downloaded files
UNCOMPRESS=${3:-no}  # Optional: "yes" to uncompress


# Download loop
while IFS= read -r url; do
    filename=$(basename "$url")
    echo "Downloading: $filename"
    
    wget -v -O "$FASTQ_DIR/$filename" "$url"
    
    # Check for download error
    if [ $? -ne 0 ]; then
        echo "Download failed for $filename"
        exit 1
    fi

    echo "Downloaded: $filename to $FASTQ_DIR"
done < "$URL_FILE"

# Optional uncompress
if [[ "$UNCOMPRESS" == "yes" ]]; then
    echo "Uncompressing all .gz files in $FASTQ_DIR"
    gunzip -fk "$FASTQ_DIR"/*.gz #k ensures keepint the gz file

    # Check if gunzip failed
    if [ $? -ne 0 ]; then
        echo "Uncompression failed"
        exit 1
    fi
fi

