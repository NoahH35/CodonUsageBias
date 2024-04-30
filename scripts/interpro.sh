#!/bin/bash

#SBATCH -A naiss2024-5-85 #naiss2024
#SBATCH -M rackham
#SBATCH -p node
#SBATCH -n 1
#SBATCH -t 1-12:00:00
#SBATCH -J interproscan
#SBATCH -o interproscan.log

module load bioinfo-tools
module load InterProScan

# Give protein fasta as arg $1
interproscan.sh --output-dir $1.interpro -cpu 20 -i $1 -dp -pa -appl Pfam --goterms --iprlookup