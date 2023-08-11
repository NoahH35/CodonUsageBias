
#prep BUSCO directory and run BUSCO 

(
mkdir BUSCO
mkdir BUSCO/assemblies
cp CDS_filtered/*/filtered*faa BUSCO/assemblies 
ln -sr scripts/busco.sh BUSCO

cd BUSCO
    nohup bash busco.sh &> busco.log &
    wait
cd .. 

cp BUSCO/busco_out/batch_summary.txt results

) 2> error_busco.log

FILE="error_busco.log";
if [ -s "$FILE" ]; 
      then
      echo "Errors found: Please check error log "error_busco.log""
      else 
      echo "all done with running BUSCO!"
fi




