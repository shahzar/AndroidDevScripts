#!/bin/bash 
# 
# 
# Script to pull SQLite database from an Android device/emulator
# By: Shahzar Ahmed
# 
# 
# 
echo "============================"
echo "=== SQLite DB Pull Script =="
echo "============================"
echo "=========== By ============="
echo "====== Shahzar Ahmed========"
echo "============================"
echo ""
# 
# 

# Temporary working directory on device
work_dir=/sdcard/development

# Android Application Package name
package=com.example.app

# Name of database
database_name=DATABASE

# [OPTIONAL] Destination directory full path where the pulled database is to be stored (Will be promted if not set)
dest_dir=""

initiateDbPull(){

	# Get Device SDK version
	sdk_ver=`adb shell getprop ro.build.version.sdk | tr -d '\r'`

	if [[ $sdk_ver -gt 19 ]]; then
		# Android Lollipop or above 
		echo "[✓] Android Lollipop or above detected"
		adb $1 exec-out run-as $package cat databases/$database_name > $dest_dir/$database_name
	else
		# Android Kitkat or below
		echo "[✓] Android Kitkat or below detected"
		adb $1 shell "run-as $package cat databases/$database_name >$work_dir/$database_name"
		adb $1 pull $work_dir/$database_name $dest_dir
	fi

	
}

setupTempDirectory(){
	# Check if dev directory available
	dir_status=$(adb shell "if [ -d $work_dir ]; then echo 'true'; else echo 'false'; fi;" | tr -d '\r')
	
	if [[ $dir_status = 'true' ]]; then
		# Directory available
		# echo "Directory found ... Fetching files ..."
		initiateDbPull
	else 
		# Directory not available
		echo "[x] Directory not available"
		adb shell "mkdir $work_dir"
		echo "[✓] Directory created ... Fetching files ..."
		initiateDbPull
	fi
} 

readDataFromUser(){
	if [[ -z $dest_dir ]]; then
		echo "Enter destination directory full path: (Hit enter to use current directory)"
		read dest_dir
		if [[ -z $dest_dir ]]; then
			dest_dir=`pwd`
		fi
		# echo "Destination: $dest_dir"
	fi
}

main(){
	readDataFromUser
	setupTempDirectory
	echo ""
	echo "[✓] Done!"
	echo "[✓] Database stored in $dest_dir"
}

main

