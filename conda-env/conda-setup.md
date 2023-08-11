Creation of the conda environments is dependend on the mamba packages, if you do not have mamba installed, please do the following before running create-conda-envs.sh  

# Install Mambaforge3 for 64-bit Linux
   
    curl -L https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh -O 
    bash -f Mambaforge-Linux-x86_64.sh
    rm Mambaforge-Linux-x86_64.sh

# Create conda environments by running 
    bash create-conda-envs.sh

# or alternatively, to run in background

    nohup bash create-conda-envs.sh &> create-conda.log &
