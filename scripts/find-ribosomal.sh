#!/bin/bash 

#clean-up directory 
# mkdir interpro/results
# mkdir interpro/results/interpro
 mkdir interpro/results/gff3 
 mkdir interpro/results/ribo_genes
 ln -sr data/ribo_genes.txt interpro/results/gff3

cd interpro
# mv AA_interpro/*interpro results/interpro
ln -sr results/interpro/*/*gff3 results/gff3
cd results/gff3

#finding ribosomal genes from the interpro scan
for domain in $(cat ribo_genes.txt);
do 
    for file in *gff3;
    do grep "Name=$domain" $file  > domains_$file.txt 
    sed -i 's/;status=.*//g' domains_$file.txt 
    done
done 

#find gene-names only - keep only first column of cvs and delete doubles 
for file in domains_*; 
  do awk '{ print $1 }' $file > tmp
  sort tmp | uniq > ribgenes_${file#domains_}
  rm tmp 
done 

# clean-up file names 
for file in domains*; do mv $file ${file%.faa.AA.gff3.txt}.gff3
for file in ribgenes*; do mv $file ${file%.faa.AA.faa.gff3.txt}.txt; done 

cd ..
mv gff3/ribgenes_* ribo_genes
