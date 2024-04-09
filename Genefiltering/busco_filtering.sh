cd BUSCO



# Concatenate all files with the same name:    
 echo "will now make a list of taxon occupancy" 
 find ./*faa/run_sordariomycetes_odb10/busco_sequences/single_copy_busco_sequences -name "*fna" | xargs -i basename {} > list.txt
 sort list.txt | uniq > list_unique.txt

# To make a list of taxon occupancy: 
 sort list.txt | uniq -c > list.taxnr.txt
 echo "we recommend to delete genes with <50% taxon occupancy, check low_occupancy.txt to see which genes have low taxon occupancy"
 find *.faa -maxdepth 0 -type d | wc -l > total.txt #total nr of directories
 awk '{print $1/2}' total.txt > half.txt #half of directories

cat half.txt | while read line ; 
do 
   echo $line;  
   for file in list.taxnr.txt; 
      do awk -v line=$line '$1 <= line {print}' $file > list_low_occupancy.txt 
   done
done  

cat half.txt | while read line ; 
do 
   echo $line;  
   for file in list.taxnr.txt; 
      do awk -v line=$line '$1 > line {print $2}' $file > list_high_occupancy.txt; 
   done
done 

echo "there are "$(cat total.txt)" genomes in total"
echo ""$(cat list_unique.txt | wc -l) "genes were found from the BUSCO dataset"
echo "of these "$(cat list_low_occupancy.txt | wc -l)" were found in less than 50% of the genomes. The rest was found in >50% of the genomes"  


