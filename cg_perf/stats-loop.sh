#!/bin/sh
cd "$(dirname "$0")"

outdir="data"
mkdir -p "$outdir"

outdir2="data-validators"
mkdir -p "$outdir2"

while [ 1 ]; do
  when=$(date +"%Y-%m-%d-%H_%M")
  outfile="$outdir/$when.csv"
  echo $outfile
  outfile2="$outdir2/validators-$when.csv"
  echo $outfile2

  ../scripts/validator cg_perf --format=csv > $outfile
  curl -s https://testnet-api.helium.wtf/v1/validators > $outfile2

  sleep 60
done
