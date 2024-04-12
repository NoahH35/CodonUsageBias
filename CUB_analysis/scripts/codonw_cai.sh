#!/bin/bash

source /home/noah/mambaforge/etc/profile.d/conda.sh
conda activate codonw-env
 
for file in cai.file; do codonw -nomenu -coa_rscu  $file ${file%faa}out ${file%faa}blk; done

