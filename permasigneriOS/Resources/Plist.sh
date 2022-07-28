#!/bin/bash
######################################## BASH LIB #######################################
bash.string.replace() {
        local text="$1" find="$2" replace="$3";

        echo "${text}" | while IFS= read -r line; do
                printf '%s\n' "${line//"$find"/$replace}";
        done
}
######################################## BASH LIB #######################################

######################################## APPLE LIB ######################################
apple.plist.read() {
        local filepath="${1}"

        defaults read "${filepath}"
}
apple.plist.convert.to.xml() {
        local filepath="${1}" tmp="${2}"

        # If second argument is passed, then we save the conversion to a new file rather than write over the original
        if [[ "${tmp}" == "true" ]]; then
            tmp="/tmp${filepath}"
        fi

        if [[ "${tmp}" != "" ]]; then
            bash.cp "${filepath}" "${tmp}"

            filepath="${tmp}"
        fi

        plutil -convert xml1 "${filepath}"

        # We also output the content which can be supressed if desired by caller
        cat "${filepath}"
}
apple.plist.convert.to.binary() {
        local filepath="${1}"

        plutil -convert binary1 "${filepath}"
}
apple.plist.write() {
        local filepath="$1" text="$2"

        echo "${text}" > "${filepath}"

        apple.plist.convert.to.binary "${filepath}" # Not sure if this step is neccessary, if xml representation is enough. Not verified or tested without.
}
apple.plist.read.search.replace.write() {
        local file="${1}" search="${2}" replacement="${3}"

        local updated=$(bash.string.replace "$(apple.plist.read "${file}")" "${search}" "${replacement}")

        apple.plist.write "${file}" "${updated}"
}
######################################## APPLE LIB ######################################


######################################## EXAMPLE ##################################
#my.test.1() {
#    apple.plist.read.search.replace.write "/tmp/com.apple.finder.plist" "/Users/" "/Home/"
#}
######################################## EXAMPLE ##################################

apple.plist.read.search.replace.write {MY_PLIST_PATH} {OLD_VALUE} {NEW_VALUE}
