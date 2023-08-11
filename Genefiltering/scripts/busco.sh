#!/bin/bash
#this script uses the sordariomycetes_odb10 dataset and an input directory called "assemblies" containing all assemblies that BUSCO should run on 
(
source /home/noah/mambaforge/etc/profile.d/conda.sh
conda activate busco-env
        for dir in assemblies; 
        do busco -l sordariomycetes_odb10 -i $dir -o busco_out -m genome -r; 
        done
conda deactivate 
) 2> error_busco_run.log 

FILE="error_busco_run.log";
if [ -s "$FILE" ]; 
      then
      echo "Errors found: Please check error log "error_busco_run.log""
      else 
      echo "all done with running BUSCO!"
fi

#END
