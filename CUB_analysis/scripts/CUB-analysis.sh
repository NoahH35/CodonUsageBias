#!/bin/bash
#this script performs CUB-analysis, using both scripts biokit.sh and codonw.sh 
(

level=$1 

cd ..
cp -r Genefiltering/results/assemblies CUB_analysis

cd CUB_analysis 

for dir in assemblies; 
    do cd $dir
        for file in filtered*; do mv $file ${file#filtered_}; done
        for file in *faa; do mkdir ${file%.faa} && mv $file ${file%.faa}; done   
        done 
cd ..

# find ribosomal genes 
bash scripts/ribosomal.sh $level #change level to desired level
# parse this file to only keep the names
grep -o "\w*147550" *tsv | sort | uniq > ribosomal_genes.txt #change level to desired level
# you now have a list of ribosomal genes 
    # find ribosomal genes in gene_filtering BUSCO output 
    # input them as reference to codonw to analyze CAI 

# make intermediate directory
mkdir intermediate
mkdir intermediate/ribosomal_genes

cd ..
cd Genefiltering/BUSCO/busco_out

 for filename in $(cat ../../../CUB_analysis/ribosomal_genes.txt); 
    do cat *.faa/run_sordariomycetes_odb10/busco_sequences/single_copy_busco_sequences/$filename > ${filename%.fna}combined.fna
    done 

# check if output is empty 
 
for file in *combined.fna;
do FILE="$file";
    if [ -s "$FILE" ]; 
     then
        echo "all done with getting ribosomal genes for ${file%combined.fna}"
     else 
      echo "no ribosomal genes in busco run. Downloading ribosomal ${file%combined.fna} fasta genes from OrthoDB"
      rm $file
        for filename in $(cat ../../../CUB_analysis/ribosomal_genes.txt); 
            do curl "https://data.orthodb.org/current/fasta?species=$level&id="$filename  -L -o $filename.faa
        done 
    fi
done


cd ../../..
mv Genefiltering/BUSCO/busco_out/*at147550* CUB_analysis/intermediate/ribosomal_genes
cd CUB_analysis
mv *tsv intermediate/ribosomal_genes
mv *txt intermediate/ribosomal_genes

# prep analysis 
for dir in assemblies/*; do ln -sr scripts/codonw.sh $dir; done 
for dir in assemblies/*; do ln -sr scripts/biokit.sh $dir; done 

# run biokit and codonw 
cd assemblies 
for dir in *
    do cd $dir
    nohup bash codonw.sh &> codonw.log &
    nohup bash biokit.sh &> biokit.log &
    cd ..
    done 
    wait

cd .. 

# run CAI analysis in some way, using a codon table made from the ribosomal genes
codonw only uses three reference swets, (option 3-7), you cannot input your own.. 

#clean up logs 
    mkdir logs 
    mkdir error_logs 
       
    cd assemblies
    for dir in *; do cp $dir/codonw.log $dir.codonw_log; done
    cd .. 
    mv assemblies/*codonw_log logs
    cd assemblies
    for dir in *; do cp $dir/biokit.log $dir.biokit_log; done
    cd ..
    mv assemblies/*biokit_log logs
    cd assemblies  
    for dir in *; do cp $dir/warnings_codonw.log $dir.codonw_error_log; done 
    cd ..
    mv assemblies/*error_log error_logs 
    cd assemblies
    for dir in *; do cp $dir/error_biokit.log $dir.biokit_error_log; done 
    cd ..
    mv assemblies/*error_log error_logs 
    
cd error_logs 
find -type f -empty -delete
cd .. 

if [ "$(ls -A error_logs)" ]; 
    then
    echo "Errors or warnings found with codon usage bias analysis for the following genomes:"
    ls error_logs
    echo "Please check error the logs in the error_logs directory"
	else
    echo "no problems found with codon usage bias analysis"
	fi

# make neutrality plots
for dir in assemblies/*; 
    do cp scripts/neutrality_plots.r $dir
done  
cd assemblies 

source /home/noah/mambaforge/etc/profile.d/conda.sh
conda activate r-env
for dir in * 
    do cd $dir && nohup Rscript neutrality_plots.r &> neutrality_plots.log 
    cd ..
    done 
wait 

) 2> error_CUB-analysis.log 

FILE="error_CUB-analysis.log";
if [ -s "$FILE" ]; 
      then
      echo "Errors found: Please check error log "error_CUB-analysis.log""
      else 
      rm $FILE
      echo "all done with CUB-analysis!"

fi

#END

