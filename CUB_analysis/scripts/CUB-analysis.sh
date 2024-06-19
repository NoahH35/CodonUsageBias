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

# run biokit on ribosomal genes 
for dir in assemblies/*; do ln -sr scripts/biokit1.sh $dir; done 
cd assemblies 
for dir in *
    do cd $dir
    nohup bash biokit.sh &> biokit1.log &
    cd ..
    done 
    wait

cd ..

# work on entire genomes 
for dir in assemblies; 
    do cd $dir
        for file in filtered*; do mv $file ${file#filtered_}; done
        for file in *faa; do mkdir ${file%.faa} && mv $file ${file%.faa}; done   
        done 
cd ..


# prep CAI by making a cai.coa file 
cd ..
cp interpro/results/ribo*/*/ribosomal_* CUB_analysis/assemblies 
cd CUB_analysis/assemblies



for file in *faa.faa; do mv $file ${file%.faa.faa}; done 
for file in ribosomal*; do mv $file ${file#ribosomal_}; done
for dir in *;
    do cd $dir 
    for file in ribosomal_*
        do mv $file $file.cai-file
    done 
    cd ..
done 
cd ..


for dir in assemblies/*; do ln -sr scripts/codonw_cai.sh $dir; done 
cd assemblies  

# run codonw_cai.sh 
for dir in *; 
    do cd $dir; 
    nohup bash codonw_cai.sh &> codonw_cai.log; 
    cd ..;    
done 


# prep analysis 
for dir in assemblies/*; do ln -sr scripts/biokit.sh $dir; done 
for dir in assemblies/*; do ln -sr scripts/codonw.sh $dir; done 


# run codonw 
cd assemblies 
for dir in *
    do cd $dir
    nohup bash codonw.sh &> codonw.log &
    nohup bash biokit.sh &> biokit.log &
    cd ..
    done 
    wait

cd .. 

# grscu info 
echo "for the grscu, the following applies: The output is col 1: the gene identifier; col 2: the gRSCU based on the mean RSCU value observed in a gene; col 3: the gRSCU based on the median RSCU value observed in a gene; and the col 4: the standard deviation of RSCU values observed in a gene."


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
    cd results/codonw; rm ribosomal*
    mkdir totals; mv *totals.out totals  
    mkdir indiv_genes; mv *out indiv_genes
    cd ..
    cd rscu
    mkdir grscu; mv *.grscu grscu
    mkdir rscu; mv *.rscu rscu
    cd rscu

# clean up rscu data for graphical interfaces 
for file in *rscu; do sort $file > sorted_$file; done 
    #add first line as filename 
    for file in sorted*; 
    do awk 'BEGIN{OFS="       "}NR==1{print "CUB",FILENAME}{print $1,$2}' $file > tmp && mv tmp $file;
    done  

#clean up filename in file 
for file in sorted*;
    do sed -i 's/sorted_//g' $file; 
    sed -i 's/.rscu//g' $file; 
done 

# concat files 
awk -v OFS=' ' '{
   a[$1][ARGIND] = $2
}
END {
   for (i in a) {
      printf "%s", i
      for (j=1; j<ARGC; j++)
         printf "%s", OFS (j in a[i] ? a[i][j] : "-----")
      print ""
   }
}' sorted* > rscu.csv

#same for AA_freq

cd ../..
cd AA_freq
for file in *charfreq; do sort $file > sorted_$file; done 
    #add first line as filename 
    for file in sorted*; 
    do awk 'BEGIN{OFS="       "}NR==1{print "AA",FILENAME}{print $1,$2}' $file > tmp && mv tmp $file;
    done  

#clean up filename in file 
for file in sorted*;
    do sed -i 's/fasta.charfreq//g' $file; 
    sed -i 's/sorted_//g' $file; 
done 

awk -v OFS=' ' '{
   a[$1][ARGIND] = $2
}
END {
   for (i in a) {
      printf "%s", i
      for (j=1; j<ARGC; j++)
         printf "%s", OFS (j in a[i] ? a[i][j] : "-----")
      print ""
   }
}' sorted* > AA_freq.csv


# concat totals 
grep "" * > totals.out 


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

