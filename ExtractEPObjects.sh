#20150731 ExtractEPObjects
#Extracts EP objects from idf file and places in new file

#useage ExtractEPObjects.sh <EP Object Name> <EP File to extract from>

EPObject=$1
file=$2

#Remove :s from EP object names for filenaming
EPObjectClean=`echo $EPObject | tr : _`

#Extract all lines between first in of object and object terminating character ";"
sed -n '/'$EPObject'/,/\;/p' $file #> "$file"_"$EPObjectClean".idf
