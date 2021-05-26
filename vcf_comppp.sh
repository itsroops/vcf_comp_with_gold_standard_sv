#!/bin/sh -l

# Calling the truvari tool for comaparisons between gold standard file and other vcf files
$1/truvari bench -b $2 -c $3 -f $5 -o $4
