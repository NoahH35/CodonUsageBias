
#!/bin/bash
#this script uses the tool Biokit from jlsteenwyk to create RSCU outputs for ribosomnal genes 
(
source /home/noah/mambaforge/etc/profile.d/conda.sh
conda activate biokit-env 

#relative synonymous codon usage 
for file in *faa.faa; do biokit rscu $file > ${file%.faa.faa}.rscu; done 

#gene wise relative synonymous codon usage 
for file in *faa.faa; do biokit grscu $file > ${file%.faa.faa}.grscu; done 

conda deactivate 



) 2> error_biokit1.log
FILE="error_biokit1.log";

if [ -s "$FILE" ]; 
      then
      echo "Errors found: Please check error log "error_biokit.log""
      else 
      echo "all done with biokit!"
fi

#END

