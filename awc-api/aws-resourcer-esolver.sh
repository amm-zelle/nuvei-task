#!/bin/bash
# Pre-requisite: 
# You must have the AWS CLI installed and configured
mapfile -t my_array < <(aws ec2 describe-regions --output text | awk '{print $4}')# Retrieves all the existing AWS Region
declare -p my_array # Store the regions as an array
# For loop to list all the resources region by region 
for i in "${my_array[@]}"
do
   
  
   echo -e '\nListing Resources in region: '$i''

   aws resourcegroupstaggingapi get-resources --region $i | grep ResourceARN
done
