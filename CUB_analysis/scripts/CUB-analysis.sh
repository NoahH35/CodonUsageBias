#!/bin/bash
#this script performs CUB-analysis, using both scripts biokit.sh and codonw.sh 
(

level=$1 

mkdir data
mkdir data/internal

cd ..
cp -r Genefiltering/results/assemblies CUB_analysis
cp -r Genefiltering/results/assemblies/* data/internal 

cd CUB_analysis 

for dir in assemblies; 
    do cd $dir
        for file in filtered*; do mv $file ${file#filtered_}; done
        for file in *faa; do mkdir ${file%.faa} && mv $file ${file%.faa}; done   
        done 
cd ..

# run CAI analysis in some way, using a codon table made from the ribosomal genes

# mkdir intermediate
# mkdir intermediate/ribosomal_genes

# find ribosomal genes 
#cd intermediate/ribosomal_genes
#curl 'https://data.orthodb.org/current/search?query=ribosomes&level='$level -L -o ribosomes.tsv

# parse this file to only keep the names
# grep -o "\w*147550" *tsv | sort | uniq > ribosomal_genes.txt #change level to desired level
# you now have a list of ribosomal genes 
    # find ribosomal genes in gene_filtering BUSCO output 
    # input them as reference to codonw to analyze CAI 

#for filename in $(cat ribosomal_genes.txt); 
#    do curl "https://data.orthodb.org/current/fasta?species=$level&id="$filename  -L -o $filename.faa
#done 

#for file in *faa; do mkdir ${file%.faa} && mv $file ${file%.faa}; done

#cd ../..
#ln -sr assemblies/*/*faa intermediate/ribosomal_genes 
#ln -sr scripts/blast.sh intermediate/ribosomal_genes 
#ln -sr scripts/codonw_cai.sh intermediate/ribosomal_genes 

#cd intermediate/ribosomal_genes 
#for dir in *at147550; do cp *faa $dir; done 
#rm *faa 

#run blast and select best hit 
#nohup bash blast.sh &> blast.log 
#wait 

#run interpro scan 

# first translate filtered sequences

    cd data/internal 
    mkdir filtered_genes 
    mv *faa filtered_genes

    module load bioinfo-tools
    module load SeqKit
    cd filtered_genes
    mkdir translated_filtered_genes 

    seqkit translate --trim $1 > $1.AA.faa && mv $1.AA.faa translated_filtered_genes
    cd ..

    mv filtered_genes/translated_filtered_genes . 
cd ..

# run interpro scan 
mkdir interpro 
ln -sr data/internal/translated_*/* interpro
ln -sr scripts/interpro.sh interpro 
cd interpro 
for file in *AA.faa; do sbatch interpro $file; done 
cd ..





# prep CAI by making a cai.coa file 
#ls */*ribo.faa > file.list
#sed 's_.*/__' file.list > tmp && mv tmp file.list

#cat file.list | while read line 
#do cat */$line > ${line%.ribo.faa}.cai-file; 
#done 

#cd ../..
#cp intermediate/ribosomal_genes/*cai-file assemblies 
#for dir in assemblies/*; do ln -sr scripts/codonw_cai.sh $fir; done 
#cd assemblies  

# prep cai.coa file 
for file in *.cai-file;
    do mv $file ${file%.cai-file};
done 

for dir in *; 
    do cd $dir; 
    nohup bash codonw_cai.sh &> codonw_cai.log; 
    cd ..;    
done 



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


# make plots
for dir in assemblies/*; 
    do cp scripts/neutrality_plots.r $dir && cp scripts/ENC_GC3.r $dir 
done  

source /home/noah/mambaforge/etc/profile.d/conda.sh
conda activate r-env
nohup Rscript scripts/install_vhcub.r 

cd assemblies 


for dir in * 
    do 
    cd $dir && nohup Rscript neutrality_plots.r &> neutrality_plots.log 
    cd ..
    cd $dir && awk '{ gsub(/[\t]/,";"); print }' $dir.out > output.txt
    nohup Rscript ENC_GC3.r &> ENC_GC3.log 
    cd ..
    done 
wait 

cd ..


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
    for dir in *; do cp $dir/ENC_GC3.log $dir.ENC.log; done 
    cd ..
    mv assemblies/*ENC.log logs 
    cd assemblies
    for dir in *; do cp $dir/neutrality_plots.log $dir.neutrality.log; done 
    cd ..
    mv assemblies/*neutrality.log logs 
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


#clean up results
mkdir results
mkdir results/ENC_GC3
mkdir results/neutrality
mkdir results/rscu 
mkdir results/codonw
mkdir results/AA_freq

    cd assemblies
    for dir in *; do cp $dir/ENC.GC3.png $dir.ENC_GC3.png; done
    cd .. 
    mv assemblies/*.ENC_GC3.png results/ENC_GC3
    cd assemblies
    for dir in *; do cp $dir/neutralityplot.png $dir.neutralityplot.png; done
    cd .. 
    mv assemblies/*.neutralityplot.png results/neutrality
    mv assemblies/*/*charfreq results/AA_freq
    mv assemblies/*/*rscu results/rscu
    mv assemblies/*/*out results/codonw

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

