#!/usr/bin/env bash

function usage {
  echo "Usage: $0 [-u USER_NAME] [-p PASSWORD] [-d WORKDIR] [-D:DROP ERROR VIEWS]"
  echo "Do not support -uroot, using -u root please."
  # too 2
  exit 2
}

function set_variable {
  local varname=$1
  shift
  if [[ -z "${!varname}" ]]; then
    eval "$varname=\"$@\""
  else
    echo "Error: $varname already set"
    usage
  fi
}

function execMysqlCommand {
    mysql -u${USER_NAME} -p${PASSWORD} --skip-column-names -e "$1"
}

function checkView {
    viewName="$1"
    # too slow
    # mysql -u${USER_NAME} -p${PASSWORD} -e "select 1 from ${viewName} limit 1" >/dev/null 2>>/home/mysql/temp/view_error
    # not good either
    # mysql -u${USER_NAME} -p${PASSWORD} -e "update ${viewName} set thisIsANotExistCol=123;" >/dev/null 2>>/home/mysql/temp/view_error
    #
    execMysqlCommand "show fields from ${viewName};" >/dev/null 2>>/home/mysql/temp/view_error
    return $?
}

function checkAllViewsAndGetErrorViews {
    echo "">/home/mysql/temp/view_error
    i=1
    for view in ${views[@]};do
        echo -n "checking $view ...$i/${#views[@]}" "..."
        checkView ${view}
        result=$?
        [[ ${result} -ne 0 ]] && echo "bad"
        [[ ${result} -ne 0 ]] && echo "pass"
        ((i++))
    done;
    cat /home/mysql/temp/view_error|grep "1356"|awk -F"'" '{print $2}'>/home/mysql/temp/error_list
    rm /home/mysql/temp/view_error -rf
    error_views=(`cat /home/mysql/temp/error_list`)
}

function printIgnoreMsg {
    [[ ${#error_views[@]} -gt 0 ]] && echo "You can add these statements to mysqldump to ignore those error views:"
    for view in ${error_views[@]};do
        echo -n " --ignore-table=${view}"
    done
    echo ""
}

function backupErrorViewsSql {
    echo "Backing up create statement of error views to ${WORKDIR}..."
    echo "" > /home/mysql/temp/backup_create_view_sql -rf
    for view in ${error_views[@]};do
        execMysqlCommand "show create view $view;" >>/home/mysql/temp/backup_create_view_sql 2>/dev/null
    done
    cat /home/mysql/temp/backup_create_view_sql|awk -F'\t' '{print $2";"}'|grep -v 'Create View;'>>/home/mysql/temp/backup_create_view
    rm -rf /home/mysql/temp/backup_create_view_sql
    echo "Done backing up create statement of error views."

}

function deleteErrorViews {
    echo "Dropping error views..."
    for view in ${error_views[@]};do
        while [[ "X" == "X${confirm}" ]];do
            read -p "please confirm to delete ${view}:(y/n)" confirm
        done
        if [[ "Xy" == "X${confirm}" ]];then
            execMysqlCommand "drop view $view;" 2>/dev/null
        fi
    done
    echo "Done dropping error views."
}

init() {
    unset DELETE_VIEWS USER_NAME PASSWORD WORKDIR

    while getopts 'u:p:d:D?h' option
    do
      case ${option} in
        d) set_variable WORKDIR $OPTARG ;;
        D) set_variable DELETE_VIEWS true ;;
        u) set_variable USER_NAME $OPTARG ;;
        p) set_variable PASSWORD $OPTARG ;;
        h|?) usage ;; esac
    done

    [[ -z "${USER_NAME}" ]] && usage
    [[ -z "${PASSWORD}" ]] && usage
    [[ -z "${WORKDIR}" ]] && set_variable WORKDIR "/home/mysql/temp" && mkdir -p ${WORKDIR}

    echo "Using directory ${WORKDIR} as temp dir."
}

getAllViews() {
    echo "Getting all views from schema..."
    views=(`execMysqlCommand "select concat(table_schema,'.',table_name) from information_schema.views where table_schema not in ('mysql','information_schema','performance_schema','sys');" 2>/dev/null`)
}

init $@
getAllViews
checkAllViewsAndGetErrorViews
printIgnoreMsg

[[ X"true" == X"${DELETE_VIEWS}" &&  ${#error_views[@]} -gt 0 ]] && backupErrorViewsSql && deleteErrorViews
