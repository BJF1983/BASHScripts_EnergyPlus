#20150731 ExtractEPClimateBasedObjects
#Extracts EP Climate based objects from file. 
#Format EP file such that a key word comment appears before and after climate based objects and 

#useage ExtractEPObjects.sh <climate key word> <EP File to extract from>

ClimateKeyword=$1
file=$2

#Extract all lines between first line of matching objects and their terminating character ";"
sed -n '/'$ClimateKeyword'/,/'$ClimateKeyword'/p' $file #> "$file"_"$EPObjectClean".idf

