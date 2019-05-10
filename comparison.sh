#!/bin/bash

RIFT=./rift
GREP=grep
OUTFILE=Docs/performance.csv

REGEX="$(head -n 1 $@)"
LINE_COUNT="$(cat $@ | wc -l)"
BYTE_COUNT="$(cat $@ | wc -c)"

RESULT_RIFT=result-rift.tmp
RESULT_GREP=result-grep.tmp
TIMESTAMP=t.tmp

touch $TIMESTAMP

echo "Running comparison for: $@"

# Append filename, line count, byte count, and regex
echo -n "$@" >> $OUTFILE
echo -n "," >> $OUTFILE
echo -n "$LINE_COUNT" >> $OUTFILE
echo -n "," >> $OUTFILE
echo -n "$BYTE_COUNT" >> $OUTFILE
echo -n "," >> $OUTFILE
echo -n "$REGEX" >> $OUTFILE
# head -n 1 $1 | xargs echo -n >> $OUTFILE
echo -n "," >> $OUTFILE


# Append rift result
tail -n +2 $@ | gtime -p -f '%e' -o $TIMESTAMP $RIFT -e -r "$REGEX" > result-rift.tmp
cat $TIMESTAMP | tr -d '\n' >> $OUTFILE
echo -n "," >> $OUTFILE

# Append grep result
tail -n +2 $@ | gtime -p -f '%e' -o $TIMESTAMP $GREP -E "$REGEX" > result-grep.tmp
cat $TIMESTAMP | tr -d '\n' >> $OUTFILE
echo -n "," >> $OUTFILE

RESULT="$(diff $RESULT_RIFT $RESULT_GREP)"

if test -z "$RESULT"; then
    echo "Identical results."
else
    echo "Results did not match."
fi

# Append match count
MATCHES="$(cat $RESULT_RIFT | wc -l)"
echo $MATCHES >> $OUTFILE

echo ""
rm $TIMESTAMP $RESULT_RIFT $RESULT_GREP
