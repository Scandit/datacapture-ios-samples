#!/usr/bin/env bash

if [ "$#" -ne 5 ]; then
    echo "Illegal number of arguments, correct usage:"
    echo "$(basename "$0") local_ipa_file local_png_file app_name app_version bundle_id"
    echo "(app_name can contain spaces)"
    exit
fi

if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

underscore_app_name=$(echo "$3" | tr " " _)

app_file_name=$(basename "$1")
app_file_extension="${app_file_name##*.}"

if [ "$app_file_extension" != "ipa" ]; then
    echo "Illegal argument: the first path should lead to a .ipa file"
    exit
fi

image_file_name=$(basename "$2")
image_file_extension="${image_file_name##*.}"

if [ "$image_file_extension" != "png" ]; then
    echo "Illegal argument: the second path should lead to a .png file"
    exit
fi

sudo aws s3api put-object --bucket scandit-product-distribution --key apps/ios/"$3"/"$underscore_app_name"_$4.ipa --body "$1" --metadata version=$4,bundle_id=$5
sudo aws s3api put-object --bucket scandit-product-distribution --key apps/ios/"$3"/"$underscore_app_name"_$4.png --body "$2"
