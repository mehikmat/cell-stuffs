#!/usr/bin/env bash

HADOOP="hadoop"
JAR="xyz.jar"
record_type_list="ABC XYZ BBC"

black='\E[30;47m'
red='\E[31;47m'
green='\E[32;47m'
blue='\E[34;47m'

TEMP_CLIENT=""
SOURCE_CLIENTS=""
TARGET_CLIENT=""

createTargetClient(){
    echo
    echo [INFO::] "Creating target client directory"
    for record_type in $record_type_list
    do
        $HADOOP fs -mkdir -p $TEMP_CLIENT/$record_type
    done
}

printUsage(){
echo [INFO::] "
     Usage:
     ./mergeFiles.sh --sources comma_separated_folder_list --target target_folder_id
     ./mergeFiles.sh -s comma_separated_folder_list -t target_folder_id
     "
}

doMerge(){
   IFS=',' read -a client_list <<< $SOURCE_CLIENTS
   for client_id in "${client_list[@]}"
   do
       echo
       echo -e $green [INFO::] "=========Running Merging process for client: $client_id============"; tput sgr0
       echo

      for record_type in $record_type_list
      do
      echo -e $blue [INFO::] "Moving record: $record_type"; tput sgr0
      file_list=`hadoop fs -ls "$client_id""/$record_type" |sed '1d;s/  */ /g' | cut -d\  -f8 | xargs -n 1 basename | grep part-`
           for file_name in $file_list
           do
                s_path="$client_id/$record_type/$file_name"
                t_path="$TEMP_CLIENT/$record_type/$client_id-$file_name"

                echo [INFO::] "Executing file command: $HADOOP fs -mv $s_path $t_path"

                $HADOOP fs -mv $s_path $t_path
           done
      done

   done
}

#parse the supplied options and save source and dest dirs
if [ $# -ne 4 ]; then
       echo
       echo [INFO::] "Error: Insufficient options"
       echo [INFO::] "Options: $@"
       echo
       printUsage
       exit 1

fi

while [[ $# > 1 ]]
do
  key="$1"

    case $key in
        -s|--sources)
        SOURCE_CLIENTS="$2"
        echo
        echo [INFO::] "Source directories: $SOURCE_CLIENTS"
        shift # past argument
        ;;

        -t|--target)
        TARGET_CLIENT="$2"
        TEMP_CLIENT="Internal_""$2"
        echo [INFO::] "Target cleint directory: $TARGET_CLIENT"
        shift # past argument
        ;;

        *)
            echo
            echo [INFO::] "Error: Unknown option: $key"
            echo
            printUsage
            exit 1
        ;;
    esac
  shift # past argument or value
done

echo -n "
         1) Merge all client files
         2) Run data update jobs for [$record_type_list]
         Please specify task to be done (eg. 2 or 1,2,3 )
        "
read tasks
IFS=', ' read -a array <<< $tasks
for number in "${array[@]}"
do
       case "$number" in
            1)

                # create target client
                createTargetClient
                # do merge
                doMerge;
                 ;;
            2)
             for record_type in $record_type_list
             do
                 type=`echo $record_type | awk -F'.' '{print $1}'`
                 echo [INFO::] "============Running data update job for: $type================="

                 $HADOOP jar $JAR -job updateDataForBOB -clientId $TARGET_CLIENT -input $TEMP_CLIENT/$record_type -output $TARGET_CLIENT//$record_type --recordType $type -jobConfig ""

                 echo [INFO::] "============Data update job for $type completed================="
             done
                 ;;
            *)
                echo
                echo [INFO::] "Invalid job number. "
                echo
                printUsage;
                exit 1
                ;;
        esac
done
