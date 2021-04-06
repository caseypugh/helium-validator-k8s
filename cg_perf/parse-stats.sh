#!/bin/sh

outfile="cg_perf.csv"
rm -f $outfile

# TODO dynamically parse current validator names
for i in attractive-vermilion-urchin short-nylon-frog broad-hemp-corgi noisy-iris-loris; do 
  echo; echo $i
  grep "$i" data/*.csv >> cg_perf.csv
done
