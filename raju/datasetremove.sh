#!/bin/sh

DatasetFile=/export/home/srcpu1/log/DataSetRmLog/datasetlod.txt
DatasetLog=/export/home/srcpu1/log/DataSetRmLog/OrchadminLog.txt
DatasetDeLog=/export/home/srcpu1/log/DataSetRmLog/datasetDelLog.txt

cd /etlstage
find -mtime +30 -name *.ds |grep -v snapshot.ds|grep -v SNAPSHOT.ds |sed "s/./\/etlstage/" >> $DatasetFile
find -mtime +30 -name *.DS |grep -v snapshot.ds|grep -v SNAPSHOT.ds |sed "s/./\/etlstage/" >> $DatasetFile

cat $DatasetFile |awk -F"/" '{print $3}'|sort |uniq |while read r
do
	apt=`echo $r | tr '[:upper:]' '[:lower:]'`
	aptfile=/opt/IBM/InformationServer/Server/Configurations/"$apt"_4node.apt
	cd /opt/IBM/InformationServer/Server/DSEngine/
	. ./dsenv
	cd bin
	if [ -f "$aptfile" ]
	then
		APT_CONFIG_FILE=$aptfile ; export APT_CONFIG_FILE

	else
		APT_CONFIG_FILE=/opt/IBM/InformationServer/Server/Configurations/EDW_4node.apt ; export APT_CONFIG_FILE
	fi

	cat $DatasetFile |grep "/$r/" |while read file
	do
		$APT_ORCHHOME/bin/orchadmin delete -f -x $file  >> $DatasetLog 2>&1
                status=$?
                if [ $status -eq 0 ]
                then
                        echo "delete successful         $file" >> $DatasetDeLog
                else
                        echo "delete fail               $file" >> $DatasetDeLog
                fi
	done
done
nowIs=$(date +'%Y-%m-%d-%T')
mv $DatasetFile $DatasetFile.$nowIs
mv $DatasetLog $DatasetLog.$nowIs
mv $DatasetDeLog $DatasetDeLog.$nowIs 
