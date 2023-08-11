#!/bin/bash
(
source /home/noah/mambaforge/etc/profile.d/conda.sh
conda activate codonw-env
#The RSCU and cai reference database were made on the ribosomal proteins using the following command: 
for file in *faa; do codonw -nomenu -enc  $file ${file%faa}out ${file%faa}blk; done
wait

conda deactivate 

) > perform_codonw.log 

    grep "Warning:" codonw.log > warnings_codonw.log 

FILE="warnings_codonw.log";
if [ -s "$FILE" ]; 
      then
      echo "Warnings or errors found: Please check error log "warnings_codonw.log""
      else 
      echo "all done with codonw!"
fi

#END