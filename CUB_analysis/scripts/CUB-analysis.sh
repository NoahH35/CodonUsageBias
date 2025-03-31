#!/bin/bash
#this script performs CUB-analysis, using both scripts biokit.sh and codonw.sh 
(

# work on entire genomes 
cd assemblies; 
        for dir in filtered*; do mv $dir ${dir#filtered_}; done

# prep CAI by making a cai.coa file 
for dir in *;
    do cd $dir 
    for file in ribosomal_*
        do mv $file $file.cai-file
    done 
    cd ..
done 

cd ..

for dir in assemblies/*; do ln -sr scripts/codonw_cai.sh $dir; done 
cd assemblies  

# run codonw_cai.sh 
for dir in *; 
    do cd $dir; 
    nohup bash codonw_cai.sh &> codonw_cai.log; 
    cd ..;    
done 
cd ..
wait

# prep analysis 
for dir in assemblies/*; do ln -sr scripts/biokit.sh $dir; done 
for dir in assemblies/*; do ln -sr scripts/codonw.sh $dir; done 


# run codonw 
cd assemblies 
for dir in *
    do cd $dir
    nohup bash codonw.sh &> codonw.log &
    nohup bash biokit.sh &> biokit.log &
    cd ..
    done 
    wait

cd .. 

# grscu info 
echo "for the grscu, the following applies: The output is col 1: the gene identifier; col 2: the gRSCU based on the mean RSCU value observed in a gene; col 3: the gRSCU based on the median RSCU value observed in a gene; and the col 4: the standard deviation of RSCU values observed in a gene."


# make plots
for dir in assemblies/*; 
    do ln -sr scripts/neutrality_plots.r $dir && ln -sr scripts/ENC_GC3.r $dir && ln -sr scripts/ENCexp-ENCobs.r $dir && ln -sr scripts/selectedGenes.r $dir
done  

source /home/noah/mambaforge/etc/profile.d/conda.sh
conda activate r-env
cd assemblies 


for dir in * 
    do 
    cd $dir && nohup Rscript neutrality_plots.r &> neutrality_plots.log 
    cd ..
    cd $dir && awk '{ gsub(/[\t]/,";"); print }' filtered_$dir.out > output.txt
    cd ..
    cd $dir && nohup Rscript selectedGenes.r &> selectedGenes.log 
    cd ..
    cd $dir && nohup Rscript ENC_GC3.r &> ENC_GC3.log 
    cd ..
    cd $dir && nohup Rscript ENCexp-ENCobs.r &> ENCpercentage.log 
    cd ..
    done 
wait 



#clean up logs 
cd ..
mkdir logs 
mkdir error_logs 
       
    cd assemblies
    for dir in *; do cp $dir/codonw.log $dir.codonw_log; done
    cd .. 
    mv assemblies/*codonw_log logs
    cd assemblies
    for dir in *; do cp $dir/biokit.log $dir.biokit_log; done
    cd ..
    mv assemblies/*biokit_log logs
    cd assemblies
    for dir in *; do cp $dir/ENC_GC3.log $dir.ENC.log; done 
    cd ..
    mv assemblies/*ENC.log logs 
    cd assemblies
    for dir in *; do cp $dir/neutrality_plots.log $dir.neutrality.log; done 
    cd ..
    mv assemblies/*neutrality.log logs 
    cd assemblies
    for dir in *; do cp $dir/selectedGenes.log $dir.selectedGenes.log; done
    cd ..
    mv assemblies/*selectedGenes.log logs
    cd assemblies  
    for dir in *; do cp $dir/warnings_codonw.log $dir.codonw_error_log; done 
    cd ..
    mv assemblies/*error_log error_logs 
    cd assemblies
    for dir in *; do cp $dir/error_biokit.log $dir.biokit_error_log; done 
    cd ..
    mv assemblies/*error_log error_logs 

cd error_logs 
find -type f -empty -delete
cd .. 

if [ "$(ls -A error_logs)" ]; 
    then
    echo "Errors or warnings found with codon usage bias analysis for the following genomes:"
    ls error_logs
    echo "Please check error the logs in the error_logs directory"
	else
    echo "no problems found with codon usage bias analysis"
	fi


#clean up results
mkdir results
mkdir results/ENC_GC3
mkdir results/neutrality-plots
mkdir results/statcor
mkdir results/rscu 
mkdir results/codonw
mkdir results/AA_freq

    cd assemblies
    for dir in *; do cp $dir/ENC.GC3.png $dir.ENC_GC3.png; done
    cd .. 
    mv assemblies/*.ENC_GC3.png results/ENC_GC3

    cd assemblies
    for dir in *; do cp $dir/GenesUnderSelection.txt  $dir.genesUnderSelection.txt; done
    cd .. 
    mv assemblies/*.genesUnderSelection.txt results/ENC_GC3


   
   
    cd assemblies
    for dir in *; do cp $dir/neutralityplot.png $dir.neutralityplot.png; done
    cd ..
    mv assemblies/*.neutralityplot.png results/neutrality-plots

    cd assemblies
    for dir in *; do cp $dir/statcor.txt $dir.statcor.txt; done 
    cd ..
    mv assemblies/*.statcor.txt results/statcor

    cd assemblies
    for dir in *; do cp $dir/encpercentage.txt $dir.enc.txt; done
    cd .. 
    mv assemblies/*.enc.txt results/codonw
    
    cp assemblies/*/*charfreq results/AA_freq
    cp assemblies/*/*rscu results/rscu
    cp assemblies/*/*out results/codonw
    
    cd results/codonw
    mkdir totals 
    mv *totals.out totals  
                  mv *enc.txt* totals 
                  cd totals 
                  for file in *enc.txt; do sed -i -e '1 i\DNC' $file; done 
                  for file in *enc.txt; do paste filtered_${file%.enc.txt}.totals.out $file > ${file%enc.txt}txt; done 
                  rm *enc*
                  for file in *txt; do sed -i "s/Average of genes/${file%.txt}/g"  $file; done 
                  rm *out
                  grep "" * > totals.out 
                  cd ..


    mkdir indiv_genes; mv *out indiv_genes
    cd ..
    cd rscu
    mkdir grscu; mv *.grscu grscu
    mkdir rscu; mv *.rscu rscu
    cd rscu

# clean up rscu data for graphical interfaces 
for file in *rscu; do sort $file > sorted_$file; done 
    #add first line as filename 
    for file in sorted*; 
    do awk 'BEGIN{OFS="       "}NR==1{print "CUB",FILENAME}{print $1,$2}' $file > tmp && mv tmp $file;
    done  

#clean up filename in file 
for file in sorted*;
    do sed -i 's/sorted_filtered_//g' $file; 
    sed -i 's/.rscu//g' $file; 
done 

# concat files 
awk -v OFS=' ' '{
   a[$1][ARGIND] = $2
}
END {
   for (i in a) {
      printf "%s", i
      for (j=1; j<ARGC; j++)
         printf "%s", OFS (j in a[i] ? a[i][j] : "-----")
      print ""
   }
}' sorted* > rscu.csv

#same for AA_freq

cd ../..
cd AA_freq
for file in *charfreq; do sort $file > sorted_$file; done 
    #add first line as filename 
    for file in sorted*; 
    do awk 'BEGIN{OFS="       "}NR==1{print "AA",FILENAME}{print $1,$2}' $file > tmp && mv tmp $file;
    done  

#clean up filename in file 
for file in sorted*;
    do sed -i 's/fasta.charfreq//g' $file; 
    sed -i 's/sorted_filtered_//g' $file; 
done 

awk -v OFS=' ' '{
   a[$1][ARGIND] = $2
}
END {
   for (i in a) {
      printf "%s", i
      for (j=1; j<ARGC; j++)
         printf "%s", OFS (j in a[i] ? a[i][j] : "-----")
      print ""
   }
}' sorted* > AA_freq.csv

cd ..

# neutrality reglines 
cd statcor 
for file in *statcor.txt; 
do mkdir ${file%.statcor.txt} && mv $file  ${file%.statcor.txt}; 
done 

for dir in *;
do cd $dir; 
    grep "p-value" *statcor.txt > statcor2.txt && grep -A 1 " cor " *statcor.txt > statcor3.txt && tr -d '\n' < statcor3.txt > statcor4.txt && paste statcor4.txt statcor2.txt > $dir.txt; 
cd ..;
done 

for dir in *; 
    do cp $dir/$dir.txt .; 
done 

# rm -r */ #deletes directories only


grep "" * > statcor.txt  
cd ..

) 2> error_CUB-analysis.log 

FILE="error_CUB-analysis.log";
if [ -s "$FILE" ]; 
      then
      echo "Errors found: Please check error log "error_CUB-analysis.log""
      else 
      rm $FILE
      echo "all done with CUB-analysis!"

fi


#END

