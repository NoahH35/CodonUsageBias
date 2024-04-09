#!/bin/bash
(
source /home/noah/mambaforge/etc/profile.d/conda.sh
conda activate codonw-env
#The RSCU and cai reference database were made on the ribosomal proteins using the following command: 
for file in *faa; do codonw -nomenu -enc -gc3s -cai  -c_type 2 $file ${file%faa}out ${file%faa}blk; done
wait


#change the above for below once we have cai_files 
for file in achmac-1*faa; do codonw -nomenu -enc -gc3s -cai  -cai_file cai.coa $file ${file%faa}out ${file%faa}blk; done

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