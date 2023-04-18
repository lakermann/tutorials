#!/bin/bash

function copy() {
  local source_bucket="$1"
  local destination_bucket="$2"
  local exclude="$3"
  local include="$4"

  aws s3 cp s3://"${source_bucket}"/ s3://"${destination_bucket}"/ \
    --recursive \
    --exclude "${exclude}" \
    --include "${include}"
}

function copy_parallel() {
  local source_bucket="$1"
  local destination_bucket="$2"

  copy "${source_bucket}" "${destination_bucket}" "*" "*0.bin" &
  copy "${source_bucket}" "${destination_bucket}" "*" "*1.bin" &
  copy "${source_bucket}" "${destination_bucket}" "*" "*2.bin" &
  copy "${source_bucket}" "${destination_bucket}" "*" "*3.bin" &
  copy "${source_bucket}" "${destination_bucket}" "*" "*4.bin" &
  copy "${source_bucket}" "${destination_bucket}" "*" "*5.bin" &
  copy "${source_bucket}" "${destination_bucket}" "*" "*6.bin" &
  copy "${source_bucket}" "${destination_bucket}" "*" "*7.bin" &
  copy "${source_bucket}" "${destination_bucket}" "*" "*8.bin" &
  copy "${source_bucket}" "${destination_bucket}" "*" "*9.bin" &
  wait
}

function set_max_concurrent_requests(){
  local max_concurrent_requests="$1"
  aws configure set default.s3.max_concurrent_requests "${max_concurrent_requests}"
}

function clean_up(){
  local bucket_name="$1"
  aws s3 rm s3://"${bucket_name}" --recursive
}

function main() {
  readonly BUCKET_NAME_SOURCE="transferlargeamountsofdata"
  readonly BUCKET_NAME_DESTINATION="transferlargeamountsofdatadestination"

  for max_concurrent_requests in 10 100 200
  do
      set_max_concurrent_requests ${max_concurrent_requests}

      clean_up ${BUCKET_NAME_DESTINATION}
      (time copy ${BUCKET_NAME_SOURCE} ${BUCKET_NAME_DESTINATION}) 2> transfer_data_using_aws_cli_${max_concurrent_requests}_max_concurrent_requests.log

      clean_up ${BUCKET_NAME_DESTINATION}
      (time copy_parallel ${BUCKET_NAME_SOURCE} ${BUCKET_NAME_DESTINATION}) 2> transfer_data_using_aws_cli_parallel_${max_concurrent_requests}_max_concurrent_requests.log
  done

  clean_up ${BUCKET_NAME_DESTINATION}
}

main "$@"
