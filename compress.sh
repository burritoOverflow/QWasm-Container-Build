#!/bin/sh

# compress a build artifact with a given command
compress() {
    NAME="$1"
    CMD="$2"
    FILE="$3"
    START=$(date +%s.%N)
    $CMD "$FILE"
    END=$(date +%s.%N)
    DURATION=$(echo "$END - $START" | bc)
    DURATION_ROUNDED=$(printf "%.2f" "$DURATION")
    echo "[Done $$] $NAME $FILE took ${DURATION_ROUNDED}s"
}


FILE="$1"
echo "[Compressing $$] $FILE"

compress "gzip" "gzip -v -k -9" "$FILE"
compress "brotli" "brotli -v -k -q 9" "$FILE"

