#!/bin/bash

#SBATCH -A naiss2024-5-85 #naiss2024
#SBATCH -M rackham
#SBATCH -p node
#SBATCH -n 1
#SBATCH -t 1-12:00:00
#SBATCH -J interproscan
#SBATCH -o interproscan.log

cd data


module load bioinfo-tools
module load SeqKit

cd filtered_genes
mkdir translated_filtered_genes 
seqkit translate --trim $1 > $1.AA.faa && mv $1.AA.faa translated_filtered_genes
cd ..

mv filtered_genes/translated_filtered_genes . 

cd ..


