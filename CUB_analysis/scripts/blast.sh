#!/bin/bash
#SBATCH -A naiss2024-5-85 #naiss2024
#SBATCH -M rackham
#SBATCH -p core
#SBATCH -n 5
#SBATCH -t 6-00:00:00
#SBATCH -J blastx
#SBATCH -o blast.log

ml bioinfo-tools
ml blast

#plast package: makeblastdb: 2.15.0+
# Package: blast 2.15.0, build Oct 19 2023 13:35:57

#cp ribosomal_genes/*faa . 
#for file in *faa; do mkdir ${file%.faa} && mv $file ${file%.faa}; done
#for file in translated_assemblies/*faa; do mv $file ${file%.faa}.NT.fa; done 
#for dir in ribosomal_genes_blast/*0; do cp translated_assemblies/*NT.fa $dir; done 

#cd ribosomal_genes_blast

#makeblastdb   
# for dir in *at147550; 
#    do cd $dir 
#    makeblastdb -in $dir.faa -dbtype prot -out reference  -logfile makeblastdb.log
#    cd ..
# done 

#run blastx

#for dir in *at147550; 
#do cd $dir 
        for file in *.NT.fa; 
        do blastx -db reference -query $file -evalue 0.005 -max_hsps 1 -max_target_seqs 1 -outfmt '6 qseqid evalue bitscore qstart qend qseq' > output_$file; 
        done 

        for file in output_*;
        do sort -k3 -nr $file | head -n 1 > unique_${file#output_} 
        done 

        for file in unique_*;
        do awk -v OFS='\t' '{print $1, $3, $5, FILENAME}' $file  > ${file#unique_}.bed 
        done    

#cd ..
#done 

module unload blast 
ml BEDTools 
#for dir in *at147550; 
#do cd $dir 
        for file in *.bed;
        do bedtools getfasta -name -fo ${file%.NT.fa.bed}.ribo.faa -fi ${file%.bed} -bed $file;
        done 
#cd ..
#done 