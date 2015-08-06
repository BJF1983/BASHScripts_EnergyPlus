#!/bin/bash

#This plot requires below Output: objects and no other Output objects

# !HEATING ENERGY
# Output:Meter:Cumulative,Heating:Electricity,runperiod; !- [J]
#
# !COOLING ENERGY
# Output:Meter:Cumulative,Cooling:Electricity,runperiod; !- [J]
#
# !FAN ENERGY
# Output:Meter:Cumulative,Fans:Electricity,runperiod; !- [J]
#
# !INTERIOR LIGHTS
# Output:Meter:Cumulative,InteriorLights:Electricity,runperiod; !- [J]
#
# !EXTERIOR LIGHTS
# Output:Meter:Cumulative,ExteriorLights:Electricity,runperiod; !- [J]
#
# !PLUGS
# Output:Meter:Cumulative,Plugs:InteriorEquipment:Electricity,runperiod; !- [J]
#
# !ATMS
# Output:Meter:Cumulative,ATMs:InteriorEquipment:Electricity,runperiod; !- [J]
# Output:Meter:Cumulative,ATMs:ExteriorEquipment:Electricity,runperiod; !- [J]


octave -q --eval \
"
meters=csvread('Combined.idf.csv');
meters(:,:)=meters(:,:)/3600000;
meters=meters(:,:)';

#Create variable for simplified meter report
#Simplidied report is
# HVAC (Heating + Cooling + Fans)
# Plugs
# Int Lighting
# Ext Lighting
# ATMs (Int ATMs + Ext ATM)


metersSimplified=[];

#Sum HVAC items (Heating + Cooling + Fans)
metersSimplified(1,1)=sum(meters(2:4,2));
#Copy Plugs value
metersSimplified(2,1)=meters(7,2);
#Copy Ext Lighting Value
metersSimplified(3,1)=meters(6,2);
#Copy Int Lighting Value
metersSimplified(4,1)=meters(5,2);
#Sum ATM items (Int ATMs + Ext ATM)
metersSimplified(5,1)=sum(meters(8:9,2));


csvwrite('temp.csv',metersSimplified(:,1));
"

echo 1,HVAC > gnuplotLabels
echo 2,Plugs >> gnuplotLabels
echo 3,Ext Lght >> gnuplotLabels
echo 4,Int Lght >> gnuplotLabels
echo 5,ATMs >> gnuplotLabels

paste -d ',' gnuplotLabels temp.csv > MeterskWh.csv

rm temp.csv gnuplotLabels

'/cygdrive/c/Program Files/gnuplot/bin/gnuplot.exe' EndUseBarChart.gnu > EndUseBarChart.png