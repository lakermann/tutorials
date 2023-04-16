#!/bin/bash

function create_bucket() {
  local bucket_name="$1"
  aws s3 mb "s3://${bucket_name}"
  aws s3api put-public-access-block \
    --bucket "${bucket_name}" \
    --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
}

function generate_files() {
  local output_folder="$1"
  for n in {1..3600}; do
    dd if=/dev/urandom of="$(printf "${output_folder}file-%04d" "$n")".bin bs=25m count=1
  done
}

function copy_data_from_local_folder_to_bucket() {
  local source_folder="$1"
  local destination_bucket="$2"
  local prefix="$3"
  aws s3 cp "${source_folder}" s3://"${destination_bucket}"/"${prefix}" \
    --recursive
}

function copy_data_within_same_bucket() {
  local bucket="$1"
  local prefix="$2"
  local to_prefix="$3"
  npx s3p cp --bucket "${bucket}" \
    --to-bucket "${bucket}" \
    --prefix "${prefix}" \
    --to-prefix "${to_prefix}"
}

function main() {
  readonly GENERATED_FILES_FOLDER="./generated-files/"
  readonly BUCKET_NAME="transferlargeamountsofdata"

  create_bucket ${BUCKET_NAME}
  generate_files ${GENERATED_FILES_FOLDER}
  copy_data_from_local_folder_to_bucket ${GENERATED_FILES_FOLDER} ${BUCKET_NAME} "date=2023-01-01/hour=00/"
  for hour in {1..23}; do
    copy_data_within_same_bucket ${BUCKET_NAME} "date=2023-01-01/hour=00/" "$(printf "date=2023-01-01/hour=%02d/" "$hour")"
  done
}

main "$@"
