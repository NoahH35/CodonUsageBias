#!/bin/bash

(
source /home/noah/mambaforge/etc/profile.d/conda.sh
conda activate codonw-env
 
for file in *cai-file; do codonw -nomenu -coa_rscu  $file $file.out $file.blk; done

) > cai_coa.log 

    grep "Warning:" cai_coa.log > warnings_cai_coa.log 