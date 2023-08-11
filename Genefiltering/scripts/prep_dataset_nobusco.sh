#!/bin/bash
#This script runs from a working directory in which the directories CDS_filtered and scripts are located. 
#CDS_filtered should contain individual directories, one per genome, which contain the genome's gff and fasta file 

(
#go into CDS_filtered; fold fasta files 
#fold fasta files if needed
source /home/noah/mambaforge/etc/profile.d/conda.sh
conda activate fastx-env
 cd CDS_filtered
    for dir in *; do cd $dir;
        for file in *faa; 
        do fasta_formatter -w 80 -i $file -o ${file%.faa}.faa1; 
        done 
        for file in *faa1; 
        do mv ${file} ${file%1}; 
    done
    cd .. 
    done 
wait
conda deactivate 

#go back to main dir and run the needed scripts 
cd .. 

#go into CDS_filtered; run filtering protocol 
for dir in CDS_filtered/*; do ln -sr scripts/gene_filtering.sh $dir; done   
cd CDS_filtered
for dir in *
    do cd $dir
    nohup bash gene_filtering.sh &> gene_filtering.log & 
    cd .. 
    done
wait 

cd ..

mkdir logs
mkdir error_logs

   cd CDS_filtered 
    for dir in *; do cp $dir/gene_filtering.log $dir.filtering_log; done
    cd ..
    mv CDS*/*filtering_log logs 
    
    cd CDS_filtered
    for dir in *; do cp $dir/error_gene_filtering.log $dir.error_logs; done
    cd .. 
    mv CDS*/*error_logs error_logs 

cd error_logs 
find -type f -empty -delete
cd .. 

if [ "$(ls -A error_logs)" ]; 
    then
    echo "Errors found with gene filtering steps: Please check error logs in the error_logs directory"
	else
    echo "no problems found with gene filtering"
	fi

ln -sr scripts/gene_counts.sh CDS_filtered
cd CDS_filtered
nohup bash gene_counts.sh &> gene_counts.log &
cd ..
wait 

#finalize outputs  
mkdir results
mkdir results/assemblies 
cp CDS_filtered/*/filtered*faa results/assemblies 

mv CDS_filtered/original_gene_counts.txt results
mv CDS_filtered/nointstop_gene_counts.txt results
mv CDS_filtered/noshortnopart_gene_counts.txt results
mv CDS_filtered/filtered_gene_counts.txt results 

cd CDS*
FILE="error_gene_counts.log";
if [ -s "$FILE" ]; 
      then
      echo "Errors found: Please check error log "error_gene_counts.log""
      cd .. 
      mv CDS*/error_gene_counts.log error_logs 
      else 
      rm error_gene_counts.log 
      echo "all done with counting the genes!"
      cd ..
fi

    rm CDS*/*sh
    mv CDS*/*log logs

) 2> error_prep_dataset.log

FILE="error_prep_dataset.log";
if [ -s "$FILE" ]; 
      then
      echo "Errors found: Please check the error_log directory for the logfile error_prep_dataset.log"
      else 
      echo "no errors found while running prep_dataset.sh: all done with dataset preparation!"
fi

mv error*log error_logs 

echo "if you want to run a BUSCO analysis on your filtered genes, do not forget to run "busco_added.sh"" 
#END
