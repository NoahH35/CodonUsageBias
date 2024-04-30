#!/bin/bash 
mkdir interpro
mkdir interpro/AA_interpro
ln -sr data/translated_filtered_genes/* interpro/AA_interpro
ln -sr scripts/interpro.sh interpro/AA_interpro
cd interpro/AA_interpro
for file in *AA.faa; do mkdir $file.interpro; done 
for file in *AA.faa; do sbatch interpro.sh $file; done 