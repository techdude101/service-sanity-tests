#!/bin/sh

getFormattedDate() {
   echo $(date --rfc-3339=seconds)
}

getResponseCode() {
  #echo "getResponseCode: $1";
  local response=$(curl -o /dev/null -s -w "%{http_code}\n"  "$1");
  echo "$response";
}

showUsage() {
  echo "Usage: ";
  echo "$0 -f <csv_file>";
}

# 1. Check dependencies are installed
curl_path=$(which curl);
cut_path=$(which cut);
date_path=$(which date);

if [ -z "$curl_path" ]; then
  echo "Curl program not found";
  exit 1;
fi

if [ -z "$cut_path" ]; then
  echo "Cut program not found";
  exit 1;
fi

if [ -z "$date_path" ]; then
  echo "Date program not found";
  exit 1;
fi

# 2. Read in arguments
while getopts f: flag
do
    case "${flag}" in
        f) filename=${OPTARG};;
    esac
done

if [ $# -lt 1 ]; then
  showUsage
  exit 1
fi

if [ ${#filename} -lt 5 ]; then
  echo "Invalid CSV filename";
  exit 1
fi

#echo "CSV Filename: $filename";

# 3. Read test data from a CSV file
exec < "$filename";
read header
#echo "Header: $header";

while read line
do

  url=$(echo "$line" | cut -d ',' -f 1);
  port=$(echo "$line" | cut -d ',' -f 2);
  path=$(echo "$line" | cut -d ',' -f 3);
  expectedResponseCode=$(echo "$line" | cut -d ',' -f 4);
  serviceName=$(echo "$line" | cut -d ',' -f 5);

  #echo "URL: $url";
  #echo "Port: $port";
  #echo "Patht: $path";
  #echo "Expected Response Code: $expectedResponseCode";

  cmd=$(echo "$url:$port$path");


  # 4. Perform HTTP requests
  echo "Service Name: $serviceName";
  echo "$cmd"
  echo -n $(getFormattedDate) "- ";
  responseCode=$(getResponseCode "$cmd");
  echo "Response Code: $responseCode";

  # 5. Log the responses
done

