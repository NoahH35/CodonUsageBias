#!/bin/bash
#this script performs CUB-analysis, using both scripts biokit.sh and codonw.sh 
(
cd ..
cp -r Genefiltering/results/assemblies CUB_analysis
cd CUB_analysis 

for dir in assemblies; 
    do cd $dir
        for file in filtered*; do mv $file ${file#filtered_}; done
        for file in *faa; do mkdir ${file%.faa} && mv $file ${file%.faa}; done   
        done 
cd ..

for dir in assemblies/*; do ln -sr scripts/codonw.sh $dir; done 
for dir in assemblies/*; do ln -sr scripts/biokit.sh $dir; done 

cd assemblies 
for dir in *
    do cd $dir
    nohup bash codonw.sh &> codonw.log &
    nohup bash biokit.sh &> biokit.log &
    cd ..
    done 
    wait

cd .. 

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

