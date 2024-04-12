# CUB_analysis
Filtering of genes and analysis of Codon Usage Bias (CUB)
This page contains procedures, scripts and analysis for CUB project. Our scripts depend on various programs and modules to run. The script create_conda-envs.sh creates conda environments for most of the needed tools, using those versions used in the analysis for the project. 
Note that these scripts were not designed to function as a fully-automated pipeline. The scripts are made to be used as a series of individual steps with manual quality control, and might not be straight forward to run in one go. Utilizing the conda-envs as created by *create-conda-envs.sh* will make it easier to utilize the scripts. However, the current set-up uses a combination of tools from different server clusters. Specifically, the blast-run and bedtools usage used by the script CUB-analysis.sh and blast.sh, assume environment modules for blast and bedtools, which are not included in the conda-envs.  As such, if you want to run these scripts, please change the blast and bedtools commands to use a local version of blast and bedtools. 

# To prepare this project, the git repository set-up will create the following file structure
Before running any scripts in the Genefiltering directory. Please do not forget to prepare your dataset in Genefiltering/CDS_filtered. This directory should contain one (1) directory for each genome, containing both its gff-file and fasta file, with extensions .gff and .faa respectively.  

    conda-env
        contains yaml files for all conda environments
        create-conda-envs.sh 
        additional tools: 
            - blast 2.15.0
            - bedtools v2.31.1

    CUB 
        Genefiltering
            CDS_filtered: in this directory, create single directories for each genome containing the .gff and .faa file for that genome 
            scripts: contains all scripts  
            prep_dataset.sh
            perform_busco.sh 
           

    CUB analysis
            scripts 
            CUB-analysis.sh 
            

# To perform the entire pipeline, including BUSCO run, run (in order) the following 

    cd conda-env 
    nohup bash create-conda-envs.sh &> create-conda.log &
    cd ..; cd Genefiltering 
    nohup bash prep_dataset.sh &> prep_dataset.log & 
    cd ..; cd CUB_analysis 
    nohup bash CUB-analysis.sh &> perform_CUB_analysis.log & 

Make sure to check the error logs. 

# To perform the entire pipeline, without BUSCO run, run (in order) the following 

    cd conda-env 
    nohup bash create-conda-envs.sh &> create-conda.log &
    cd ..; cd Genefiltering 
    nohup bash prep_dataset.sh &> prep_dataset.log & 
    cd ..; cd CUB_analysis 
    nohup bash CUB-analysis.sh &> perform_CUB_analysis.log & 

# note: a BUSCO run can always be added later by running busco_added.sh from the Genefiltering directory like so: 
    cd Genefiltering 
    ln -sr scripts/busco_added.sh .
    nohup bash busco_added.sh &> perform_busco.log & 

Make sure to check the error logs when needed. 