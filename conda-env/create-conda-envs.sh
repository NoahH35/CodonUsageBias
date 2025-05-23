#!/bin/bash
(
#This script runs from a working directory in which the directories CDS_filtered and scripts are located. 
source /home/noah/mambaforge/etc/profile.d/conda.sh
mamba env create trnascan-se
    conda activate trnascan-se 
    mamba install bioconda::trnascan-se # v2.0.9
    conda deactivate 
mamba env create -f codonw-environment.yml
mamba env create -f fastx-environment.yml 
mamba env create -f biokit-environment.yml
    source activate biokit-env 
    pip install jlsteenwyk-biokit -U #v0.1.2
    source deactivate 

mamba env create -f agat-environment.yml
mamba create -n busco-env 
    source activate busco-env 
    mamba install -c conda-forge -c bioconda busco=5.4.7
    source deactivate 

mamba env create -f r-env.yml
mamba env create -f seqtk-environment.yml

) 2> error_create_conda_env.log 

FILE="error_create_conda_env.log";
if [ -s "$FILE" ]; 
      then
      echo "Errors found: Please check error log "error_conda_env.log""
      else 
      echo "all done with creating conda environments!"
fi

#END