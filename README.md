# CUB_analysis
Filtering of genes and analysis of Codon Usage Bias (CUB)


# To prepare this project, the git repository set-up will create the following file structure
Before running any scripts in the Genefiltering directory. Please do not forget to prepare your dataset in Genefiltering/CDS_filtered. This directory should contain one (1) directory for each genome, containing both its gff-file and fasta file, with extensions .gff and .faa respectively.  

    conda-env
        contains yaml files for all conda environments
        create-conda-envs.sh 

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

Make sure to check the error logs when needed. 

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