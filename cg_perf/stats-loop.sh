#!/bin/sh
cd "$(dirname "$0")"

outdir="data"
mkdir -p "$outdir"

while [ 1 ]; do
  when=$(date +"%Y-%m-%d-%H_%M")
  outfile="$outdir/$when.csv"
  echo $outfile

  ../scripts/validator cg_perf --format=csv > $outfile
  ../scripts/validator ledger_validators > data-ledger/$when

  sleep 60
done
