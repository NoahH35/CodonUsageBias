# run CAI analysis in some way, using a codon table made from the ribosomal genes
#run interpro scan 
# first translate filtered sequences

source /home/noah/mambaforge/etc/profile.d/conda.sh
source activate seqtk-env

# prep-dataset
    
    for file in *txt; do mkdir ${file%.txt} && mv $file ${file%.txt}; done 
    for dir in *ribgenes_*; do mv $dir ${dir#ribgenes_}; done 
    cd ../../.. 

    cp data/filtered_genes/*faa interpro/results/ribo_genes
    cd interpro/results/ribo_genes
    for file in filtered*; 
        do mv $file ${file#filtered_} 
    done 

    for file in *faa; 
        do mv $file ${file%.faa}
    done 

# isolate ribosomal genes 

for dir in *; 
    do cd $dir 
    for file in *faa; 
        do seqtk subseq $file *txt > ribosomal_$file.faa
    done
    cd ..
done 


