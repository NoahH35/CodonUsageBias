#!/bin/bash
(
source /home/noah/mambaforge/etc/profile.d/conda.sh
conda activate agat-env

#set-up WD 
mkdir intermediate 

#note those genes where the combined CDS < 100 bp or which have partial codons: all  
for file in *gff; do agat_sp_extract_sequences.pl -g $file -f *faa -o all_${file%.gff}.faa; done 
sed -i '/^>/ s/ .*//' all_*.faa

for file in all*faa; do seqkit fx2tab --length --name --header-line  all*.faa > ${file%.faa}.txt; done 


        #print combined CDS < 100 bp 
        for file in all*txt; do awk '$2 < 100' $file > small_${file#all_}; done 
        for file in small*txt; do awk '{print $1}' $file > short_genes_kill_list.txt; done 

        #print codon lengths 
        awk '{print $1, $2/(3)}' all*txt > partial.txt
        grep '\.' partial.txt > partial_codons.txt
        awk '{print $1}' partial_codons.txt > partial_kill_list.txt 
        mv partial_codons.txt intermediate
        mv partial.txt intermediate 
        mv small*txt intermediate
        mv all* intermediate

        #concat files 
        cat partial_kill_list.txt short_genes_kill_list.txt > shortpart.txt 
        sort shortpart.txt | uniq > short_partial_kill_list.txt
        mv shortpart.txt intermediate 
        mv partial* intermediate 
        mv short_genes* intermediate  

#filter out genes with total CDS length <100 bp, or which contain partial codons: 1
FILE="short_partial_kill_list.txt";
if [ -s "$FILE" ]; 
      then
      for file in *gff; do agat_sp_filter_feature_from_kill_list.pl --gff $file --kill_list short_partial_kill_list.txt  --output 1_$file; done 
      mv 1*txt intermediate 
      else 
      for file in *gff; do cp $file 1_$file; done 
fi

mv short_partial_kill_list.txt intermediate 

#add start and stop codons where needed: 2
for file in 1*gff; do agat_sp_add_start_and_stop.pl --gff $file --fasta *.faa --out 2_${file#1_}; done 
mv 1*gff intermediate 
 
#flag internal stop codons in mRNA: 3
        for file in 2*gff; do agat_sp_flag_premature_stop_codons.pl -gff $file --fasta *.faa --out 3_${file#2_}; done

        # transport int files to intermediate 
        mv 3*txt intermediate
        mv 2*gff intermediate 

        #make kill lists containing pseudogenes
        #only genes where all mRNA contain internal stopcodons are flagged as pseudogenes
        awk '{if ($9 ~ /pseudo=.*/) print $9}' 3*gff > intstop_kill_list.txt 
        sed -i -e 's/;pseudo=.*//g;s/ID=//g' intstop_kill_list.txt 
      
#delete genes with internal stop codons: 4  
FILE="intstop_kill_list.txt";
if [ -s "$FILE" ]; 
      then
      for file in 3*gff; do agat_sp_filter_feature_from_kill_list.pl --gff $file --kill_list intstop_kill_list.txt  --output 4_${file#3_}; done 
      mv *txt intermediate 
      else 
      for file in 3*gff; do cp $file 4_${file#3_}; done 
fi
 
        #transport int files to intermediate 
        mv 3* intermediate 
        
 
#note CDS which miss start and/or stop: 5   
        for file in 4*gff; do agat_sp_filter_incomplete_gene_coding_models.pl --add_flag --gff $file --fasta *faa  -o 5_${file#4_}; done 

        mv 4* intermediate 
        mv *incomplete* intermediate 
        awk '{if ($9 ~ /incomplete=/) print $9}' 5*gff > incomplete_kill_list.txt
        sed -i -e 's/;incomplete=.*//g;s/ID=//g;s/;Parent=.*//g;' incomplete_kill_list.txt 
                             
#delete CDS which miss start AND/OR stop: 6  
FILE="incomplete_kill_list.txt";
if [ -s "$FILE" ]; 
      then
      for file in 5*gff; do agat_sp_filter_feature_from_kill_list.pl --gff $file --kill_list incomplete_kill_list.txt  --output 6_${file#5_}; done  
      mv *txt intermediate 
      else 
      for file in 5*gff; do cp $file 6_${file#5_}; done 
fi
                
        #transport int files to intermediate 
        mv 5* intermediate 
      
#extract cds from fasta file 
        for file in 6*gff; do agat_sp_extract_sequences.pl -g $file -f *faa -o ${file%.gff}.faa; done 
        for file in 6*faa; do mv $file filtered_${file#6_}; done 
        for file in 6*; do mv $file filtered_${file#6_} && mv filtered_${file#6_} intermediate; done 

#clean up files 
        mv *index intermediate  
        
conda deactivate 

) 2> error_gene_filtering.log 

sed -i '/.*Parsing:/d' error_gene_filtering.log
sed -i '/Possible/d' error_gene_filtering.log 

FILE="error_gene_filtering.log";
if [ -s "$FILE" ]; 
      then
      echo "Errors found: Please check error log "error_gene_filtering.log""
      else 
      touch error_gene_filtering.log 
      echo "all done with gene filtering!"
fi

#END