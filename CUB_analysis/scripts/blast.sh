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


for dir in *at147550; 
    do cd $dir 
        for file in *.NT.fa; 
        do blastx -db reference -query $file -evalue 0.005 -max_hsps 1 -max_target_seqs 1 -outfmt '6 qseqid evalue bitscore qstart qend qseq' > output_$file; 
        done 

        for file in output_*;
        do sort -k3 -nr $file | head -n 1 > unique_${file#output_} 
        done 

        for file in unique_*;
        do awk -v OFS='\t' '{print $1, $3, $5, FILENAME}' $file  > ${file#unique_}.bed 
        done    

    cd ..
done 

module unload blast 
ml BEDTools 

for dir in *at147550; 
    do cd $dir 
        for file in *.bed;
        do bedtools getfasta -name -fo ${file%.NT.fa.bed}.ribo.faa -fi ${file%.bed} -bed $file;
        done 
    cd ..
done 