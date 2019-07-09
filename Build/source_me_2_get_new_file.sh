#!/usr/bin/env bash
CURR_DIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
POSTS_DIR=$(cd "${CURR_DIR}/../source/_posts/"; pwd)

YEAR=$(date '+%Y')
DOC_PREFIX=$(date '+%Y%m%d')
TITLE="$1"
[[ -z "${TITLE}" ]] && TITLE="basic"
FILENAME="${DOC_PREFIX}_${TITLE}.adoc"
FILEDIR_FULL_PATH="${POSTS_DIR}/${YEAR}/"
FILE_FULL_PATH="${POSTS_DIR}/${YEAR}/${FILENAME}"
[[ ! -d "${FILEDIR_FULL_PATH}" ]] && mkdir -p "${FILEDIR_FULL_PATH}"

[[ -f "${FILE_FULL_PATH}" ]] && { echo "${FILE_FULL_PATH} exists.";exit 1; }
cp "${CURR_DIR}"/basic.adoc "${FILE_FULL_PATH}"
sed -i "s/{{basic_title}}/${TITLE}/g" "${FILE_FULL_PATH}"

echo "successfully created ${FILE_FULL_PATH}"
echo "will cd $FILEDIR_FULL_PATH"
cd $FILEDIR_FULL_PATH
