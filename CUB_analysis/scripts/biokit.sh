#!/bin/bash
#this script uses the tool Biokit from jlsteenwyk to create RSCU outputs and GC1-2-3 data 
(
source /home/noah/mambaforge/etc/profile.d/conda.sh
conda activate biokit-env 

#relative synonymous codon usage 
for file in *faa; do biokit rscu $file > ${file%.faa}.rscu; done 

#gene wise relative synonymous codon usage 
for file in *faa; do biokit grscu $file > ${file%.faa}.grscu; done 

#gc content per codon position
biokit gc_content_first_position *faa -v > gc1
biokit gc_content_second_position *faa -v > gc2
biokit gc_content_third_position *faa -v > gc3


# translate to AA 
for file in *faa; do cp  $file ${file%.faa}fasta; done 
for file in *fasta; do biokit trans_seq $file > ${file%.fasta}.translated.fa; done  
# calculate char frequency
for file in *translated.fa; do biokit char_freq $file > ${file%.translated.fa}.charfreq; done 



conda deactivate 



) 2> error_biokit.log
FILE="error_biokit.log";

if [ -s "$FILE" ]; 
      then
      echo "Errors found: Please check error log "error_biokit.log""
      else 
      echo "all done with biokit!"
fi

#END

