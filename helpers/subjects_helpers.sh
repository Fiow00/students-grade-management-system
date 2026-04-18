show_subjects() {
    if [[ -z "$(ls -A "$SUBJECTS_DIR")" ]]
    then
        echo "No subjects found."
        return 1
    fi

    {
        echo "Code|Name|Credits"
        for subject in "$SUBJECTS_DIR"/*.sub
        do
            awk -F= '
                /^CODE=/    {code=$2}
                /^NAME=/    {name=$2}
                /^CREDITS=/ {credits=$2}
                END { print code "|" name "|" credits }
            ' "$subject"
        done
    } | column -t -s '|'
}

is_valid_code() {
    local code=$1

    if [[ -z "$code" ]]
    then
        echo "Error: Subject code cannot be empty."
        return 1
    elif [[ ! "$code" =~ ^[a-zA-Z]{2,5}[0-9]{2,4}$ ]]
    then
        echo "Error: Code must be 2-5 letters followed by 2-4 digits (e.g. CS101)."
        return 1
    else
        local letters="${code//[0-9]/}"
        local first_char="${letters:0:1}"
        local rest="${letters//$first_char/}"

        if [[ -z "$rest" ]]
        then
            echo "Error: Subject code letters cannot all be the same"
            return 1
        fi
    fi

    return 0
}

is_valid_subject_name() {
    local name=$1

    if [[ -z "$name" ]]
    then
        echo "Error: Subject name cannot be empty."
        return 1
    elif [[ ! "$name" =~ ^[a-zA-Z[:space:]]+$ ]]
    then
        echo "Error: Name must contain letters only."
        return 1
    elif [[ ! "$name" =~ ^[a-zA-Z[:space:]]{3,50}$ ]]
    then
        echo "Error: Subject name must be 3-50 letters long."
        return 1
    else
        local clean_name="${name// /}"
        local first_char="${clean_name:0:1}"
        local rest="${clean_name//$first_char/}"

        if [[ -z "$rest" ]]
        then
            echo "Error: Name cannot consist of the same letter repeated."
            return 1
        fi
    fi

    return 0
}

is_valid_credits() {
    local credits=$1

    if [[ -z "$credits" ]]
    then
        echo "Error: Credit hours cannot be empty."
        return 1
    elif [[ ! "$credits" =~ ^[1-6]$ ]]
    then
        echo "Error: Credit hours must be an integer between 1 and 6."
        return 1
    fi

    return 0
}