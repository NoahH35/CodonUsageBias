#!/bin/bash
(
source /home/noah/mambaforge/etc/profile.d/conda.sh
conda activate codonw-env

 
for file in *faa; do codonw -nomenu -enc -gc3s -cai  -c_type 2 $file ${file%faa}out ${file%faa}blk; done
wait


#change the above for below once we have cai_files 
# cai files are made by running correspondance analysis on RSCU in codonw, this outputs automatically cai.coa
# does not work for now as we only get AA outputs for our ribosomal genes... 
# for file in achmac-1*faa; do codonw -nomenu -enc -gc3s -cai  -cai_file cai.coa $file ${file%faa}out ${file%faa}blk; done

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