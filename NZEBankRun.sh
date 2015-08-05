#20150731 NZEBankRun.sh
#Run NZE bank simulation for specific climate and HVAC system

#useage NZEBankRun.sh <climate [1a | 2a | 2b | etc]> <code basis [90.7 | AEDG | Optimized]> <HVAC System [RTU | VRF | GTHP]> <simulation name>

#NZE Bank "base" files should be placed in ./NZEBankBaseFiles
#Climate specific construction files should be placed in ./ClimateFiles/[1a | 2a | 2b | etc]/Constructions/[90.7 | AEDG | Optimized]
#Climate specific weather files should be placed in ./ClimateFiles/[1a | 2a | 2b | etc]/WeatherFiles
#HVAC files should be placed in ./HVACSystems/[RTU | VRF | GTHP]

#Parameter file (ParameterFile.csv) can be used
#This should be a csv file. The first column should be the key word pattern to
#be repaced in the compiled IDF file for the simulation.
#The second column should be the value to replace its associate variable with.
#A third column may be used for comments.

#Simulation name to identify the created IDF file and associated simulation files
#This name will be appenned to the climate zone and HVAC system type

#Check for input errors
ERROR=""
if [ -z $1 ]; then ERROR=true; fi
if [ -z $2 ]; then ERROR=true; fi
if [ -z $3 ]; then ERROR=true; fi
if [ -z $4 ]; then ERROR=true; fi
if [ "$ERROR" == "true" ]; then echo "Error. Need more input. Usage: ./NZEBankRun.sh <climate> <code basis> <HVAC System> <Simulation Name>"; exit; fi

#Display script parameters back to user and use tee to also send this to a log file
Climate=$1;          							
Code=$2;          							
HVACSystem=$3;       							
SimName=$4;		 								
WeatherFile=`ls ClimateFiles/$Climate/WeatherFiles/*epw`; 	
ParameterFile=ParameterFile.csv;				

#Make sure this simulation run will not overwrite existing files
if [ -d "$SimFolder" ]; then echo "Careful $SimFolder already exists. Rename or delete existing folder or change this simulation's run name."; exit; fi

#Create simulation folder variable
SimFolder=RUN_"$Climate"_"$HVACSystem"_"$SimName"
#Make simulation folder and folder for individual IDF files
mkdir ./$SimFolder 2>/dev/null
mkdir ./$SimFolder/IndividualIDFFiles

echo "" | tee -a ./$SimFolder/log.txt
echo "Climate:       "$Climate | tee -a ./$SimFolder/log.txt
echo "Code:          "$Code | tee -a ./$SimFolder/log.txt
echo "HVACSystem:    "$HVACSystem | tee -a ./$SimFolder/log.txt
echo "SimName:       "$SimName | tee -a ./$SimFolder/log.txt
echo "WeatherFile:   "$WeatherFile | tee -a ./$SimFolder/log.txt
echo "ParameterFile: "$ParameterFile | tee -a ./$SimFolder/log.txt
echo "" | tee -a ./$SimFolder/log.txt



#Copy all base files and schedule folder (if it exists) to the simulation folder
cp -r ./NZEBankBaseFiles/* ./$SimFolder/IndividualIDFFiles

#Copy HVAC system files to simulation folder
cp ./HVACSystems/$HVACSystem/* ./$SimFolder/IndividualIDFFiles

#Copy climate specific files to simulation folder
cp ./ClimateFiles/$Climate/Constructions/$Code/*.idf ./$SimFolder/IndividualIDFFiles
cp ./ClimateFiles/$Climate/WeatherFiles/*.ddy ./$SimFolder/IndividualIDFFiles
cp ./ClimateFiles/$Climate/WeatherFiles/*.idf ./$SimFolder/IndividualIDFFiles

#Convert all input files to unix format for processing
dos2unix -q ./$SimFolder/IndividualIDFFiles/* 

#Concatenate all input files
cat ./$SimFolder/IndividualIDFFiles/* 2> /dev/null > ./$SimFolder/Combined.idf

#Copy and folders that might be in the IndividualIDFFiles folder.
#These may include folders that contain schedules
cp -r `ls -d ./$SimFolder/IndividualIDFFiles/*/` ./$SimFolder

#Read in parameters from parameterfile
echo "Parameters:"
for x in `tail -n +2 $ParameterFile | cut -f1-2 -d ','`
do
	ParmName=`echo $x | cut -f1 -d','`
	ParmVal=`echo $x | cut -f2 -d ','`
	echo $ParmName $ParmVal | tee -a ./$SimFolder/log.txt
	sed -i 's/'$ParmName'/'$ParmVal'/g'  ./$SimFolder/Combined.idf
done

#Copy weather file
cp $WeatherFile $SimFolder
#Change weather file variable for simulation. Remove directory path
WeatherFile=`echo $WeatherFile | cut -f4 -d '/'`

#Copy the main EnergyPlus executable to the simulation folder
cp RunEPlus_Local.bat $SimFolder

#Change working directory to simulation folder. This is where simulations will be exectued.
cd $SimFolder

#Run EnergyPlus
./RunEPlus_Local.bat `echo Combined.idf "$WeatherFile" | tr '/' '\'`

