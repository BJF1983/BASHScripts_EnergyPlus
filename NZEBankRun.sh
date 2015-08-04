#20150731 NZEBankRun.sh
#Run NZE bank simulation for specific climate and HVAC system

#useage NZEBankRun.sh <climate (1a,2a,2b,etc) <RTU | VRF | GTHP> <simulation name>

#NZE Bank "base" files should be placed in ./NZEBankBaseFiles
#Climate specific files should be placed in ./ClimateFiles/<1a,2a,2b,etc>
#HVAC files should be placed in ./HVACSystems/<RTU | VRF | GTHP>

#Parameter file to use
#This should be a csv file. The first column should be the key word pattern to
#be repaced in the compiled IDF file for the simulation.
#The second column should be the value to replace its associate variable with.
#A third column may be used for comments.

#Simulation name to identify the created IDF file and associated simulation files
#This name will be appenned to the climate zone and HVAC system type

ERROR=""
if [ -z $1 ]; then ERROR=true; fi
if [ -z $2 ]; then ERROR=true; fi
if [ -z $3 ]; then ERROR=true; fi
if [ "$ERROR" == "true" ]; then echo "Error. Need more input. Usage: ./NZEBankRun.sh <climate> <HVAC System> <Simulation Name>"; exit; fi



echo ""
Climate=$1;          							echo "Climate:       "$Climate
HVACSystem=$2;       							echo "HVACSystem:    "$HVACSystem
SimName=$3;		 								echo "SimName:       "$SimName
WeatherFile=`ls ClimateFiles/$Climate/*epw`; 	echo "WeatherFile:   "$WeatherFile
ParameterFile=ParameterFile.csv;				echo "ParameterFile: "$ParameterFile
echo ""

SimFolder=RUN_"$Climate"_"$HVACSystem"_"$SimName"

if [ -d "$SimFolder" ]; then echo "Careful $SimFolder already exists. Rename or delete existing folder or change this simulation's run name."; exit; fi

#Make simulation folder
mkdir ./$SimFolder 2>/dev/null

#Copy all base files and schedule folder (if it exists) to the simulation folder
cp -r ./NZEBankBaseFiles/* ./$SimFolder

#Copy HVAC system files to simulation folder
cp ./HVACSystems/$HVACSystem/* ./$SimFolder

#Copy climate specific files to simulation folder
cp ./ClimateFiles/$Climate/*.idf ./$SimFolder
cp ./ClimateFiles/$Climate/*.ddy ./$SimFolder

#Convert all input files to unix format for processing
dos2unix -q ./$SimFolder/* 

#Concatenate all input files
cat ./$SimFolder/* 2> /dev/null > ./$SimFolder/Combined.idf

#Read in parameters from parameterfile
echo "Parameters:"
for x in `tail -n +2 $ParameterFile | cut -f1-2 -d ','`
do
	ParmName=`echo $x | cut -f1 -d','`
	ParmVal=`echo $x | cut -f2 -d ','`
	echo $ParmName $ParmVal
	sed -i 's/'$ParmName'/'$ParmVal'/g'  ./$SimFolder/Combined.idf
done

#Copy weather file
cp $WeatherFile $SimFolder
#Change weather file variable for simulation
WeatherFile=`echo $WeatherFile | cut -f3 -d '/'`

cp RunEPlus.bat $SimFolder
cd $SimFolder

RunEPlus.bat `echo Combined.idf $WeatherFile | tr '/' '\'`

# ParamFile=20150723_ThermalResponseParameters_BJF.txt

# #Extract all lines between first line of matching objects and their terminating character ";"
# sed -n '/'$ClimateKeyword'/,/'$ClimateKeyword'/p' $file #> "$file"_"$EPObjectClean".idf

