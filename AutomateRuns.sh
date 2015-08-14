RunName=Test1

for climates in 1a 2a 2b 3a 3b-Ca 3b-Other 3c 4a 4b 4c 5a 5b 6a 6b 7 8 
do 
	for codes in Optimized
	do 
		for hvacs in RTU
		do
			echo ./NZEBankRun.sh $climates $codes $hvacs "$climates"_"$codes"_"$hvacs"_"$RunName"
		done
	done
done