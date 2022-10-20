#!/bin/bash

showHelp()
{
	# Display Help
	echo -e "\e[1mGet AWS files using the s3api using the AWS CLI \e[0m"
	echo
	echo "Syntax: bash s3apiAWSGetFile.sh [-f|e|b|p|help]"
	echo
	echo "Double click CTRL + C to close running script"
	echo
	echo "Options:"
	echo -e "-f     File name being downloaded e.g. \e[1m mongo-database-dump \e[0m"
	echo -e "-e     Extension of file name being downloaded e.g. \e[1m zip \e[0m"
	echo -e "-b     Bucket name file is found in e.g. \e[1m mongo-database-snapshot-bucket \e[0m"
	echo -e "-p     AWS role profile name being used e.g. \e[1m developer \e[0m"
	echo -e "-s     Size of file in bytes e.g. \e[1m 10000 \e[0m"
	echo -e "-help  Print this \e[1mhelp screen \e[0m"
	echo
}

parameterInputError() {
	showInfo "$1" 
	showHelp 
	exit
}

showInfo() {
	echo
	echo "======================================================="
	echo -e ${1}
	echo "======================================================="
	echo
}

numbRegex='^[0-9]+$'

while getopts f:e:b:p:s:h: option
do
	case "${option}" in
        f) file=${OPTARG};;
        e) extension=${OPTARG};;
        b) bucket=${OPTARG};;
        p) profile=${OPTARG};;
		s)
          if ! [[ ${OPTARG} =~ $numbRegex ]] ; then showInfo "Error: The \e[1mfpsvalue\e[0m i.e \e[1m-f\e[0m is empty or not a number!";  exit; else size=${OPTARG}; fi ;;
        h) 
          if ! [[ ${OPTARG} == "elp" ]] ; then showInfo "Error: The \e[1mhelp\e[0m argument should be \e[1m-help\e[0m."; exit; else showHelp; exit; fi;;
        *) showInfo "Error: Invalid option selected or paramenter not correctly filled!"; exit;;
    esac
done

if [[ -v file ]]; then showInfo "File name selected is $file"; else parameterInputError "Error: You have not entered the file name"; fi
if [[ -v extension ]]; then showInfo "File extension selected is $extension"; else parameterInputError "Error: You have not entered the file extension"; fi
if [[ -v bucket ]]; then showInfo "AWS bucket name selected is $bucket"; else parameterInputError "Error: You have not entered the AWS bucket name"; fi
if [[ -v profile ]]; then showInfo "AWS profile name selected is $profile"; else parameterInputError "Error: You have not entered the AWS profile name"; fi
if [[ -v size ]]; then showInfo "File size in bytes selected is $size"; else parameterInputError "Error: You have not entered the file size bytes"; fi



showInfo "Command has been initiated for $file.$extension"

fileSize=$(stat --printf="%s" $file.$extension)

if ! [[ $fileSize =~ $numbRegex ]] ; then 
	fileSize=0
	showInfo "Initial file size is not set. So it has been initialised to $fileSize."
fi

showInfo "Initial file size is $fileSize for $file.$extension. Starting download..."

while  [ $fileSize -lt $size ]
do
	showInfo "Download has started for $file.$extension...."
	aws s3api get-object --debug --profile $profile --bucket $bucket --key $file.$extension --range "bytes=$fileSize-" "$file.part"
    showInfo "Download has stopped for $file.$extension..."
	cat "$file.part" >> "$file.$extension"
	showInfo "File '$file.part' has been appended to '$file.$extension'."
	fileSize=$(stat --printf="%s" $file.$extension)
	showInfo "File size has increased by $fileSize."
done

showInfo "Download completed for $file.$extension"
