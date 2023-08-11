#!/bin/bash

#run this script inside the directory containing each genome directory 
# fill in the paths to your directories 
(
#make needed directories:
    #unfiltered
    mkdir unfiltered_gene; ln -sr */*gff unfiltered_gene  
    #no short and no partial codons  
    mkdir noshortnopart_gene; ln -sr */intermediate/1*gff noshortnopart_gene
    #delete genes with internal stop codons: 4 
    mkdir nointstop_gene; ln -sr */intermediate/4*gff nointstop_gene
    #delete CDS which miss start AND/OR stop: 5  
    mkdir noincomplete_gene; ln -sr */intermediate/5*gff noincomplete_gene
    #only filtered 
    mkdir filtered_gene; ln -sr */intermediate/filtered*gff filtered_gene

#create gene counts 
cd unfiltered_gene 
for file in *gff; 
    do grep "gene" $file | wc -l > gene_$file 
done  

grep "" gene* > original_gene_counts.txt
cd ..

#filter out genes with total CDS length <100 bp, or which contain partial codons: 1
cd noshortnopart_gene 
for file in 1*gff; 
    do grep "gene" $file | wc -l > gene_$file 
done  
grep "" gene* > noshortnopart_gene_counts.txt
cd ..

#delete genes with internal stop codons: 4 
cd nointstop_gene
for file in 4*gff; 
    do grep "gene" $file | wc -l > gene_$file 
done  
grep "" gene* > nointstop_gene_counts.txt
cd ..

#delete CDS which miss start AND/OR stop: 6 / filtered 
cd filtered_gene
for file in filtered*gff; 
    do grep "gene" $file | wc -l > gene_$file 
done  
grep "" gene* > filtered_gene_counts.txt
cd ..

#put count files in current directory 
mv unfiltered_gene/original_gene_counts.txt .
mv noshortnopart_gene/noshortnopart_gene_counts.txt . 
mv nointstop_gene/nointstop_gene_counts.txt .
mv filtered_gene/filtered_gene_counts.txt .

#delete intermediates for counting 
rm -r unfiltered_gene 
rm -r noshortnopart_gene
rm -r nointstop_gene 
rm -r noincomplete_gene
rm -r filtered_gene
) 2> error_gene_counts.log 



#END 