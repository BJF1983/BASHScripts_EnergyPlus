#!/bin/bash

octave -q --eval \
"
meters=csvread('Combined.idf.csv');
meters(:,:)=meters(:,:)/3600000;
meters=meters(:,:)';
csvwrite('temp.csv',meters(:,2));
"

head -n 1 Combined.idf.csv | tr ',' '\n' > temp2.csv

dos2unix -q temp.csv temp2.csv

paste -d ',' temp2.csv temp.csv > MeterskWh.csv

sed -i -e 's/[J]/[kWh]/g' MeterskWh.csv