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
        echo "Error: Subject code cannot be empty." >&2
        return 1
    elif [[ ! "$code" =~ ^[a-zA-Z]{2,5}[0-9]{2,4}$ ]]
    then
        echo "Error: Code must be 2-5 letters followed by 2-4 digits (e.g. CS101)." >&2
        return 1
    else
        local letters="${code//[0-9]/}"
        local first_char="${letters:0:1}"
        local rest="${letters//$first_char/}"

        if [[ -z "$rest" ]]
        then
            echo "Error: Subject code letters cannot all be the same" >&2
            return 1
        fi
    fi

    return 0
}

is_valid_subject_name() {
    local name=$1

    if [[ -z "$name" ]]
    then
        echo "Error: Subject name cannot be empty." >&2
        return 1
    elif [[ ! "$name" =~ ^[a-zA-Z[:space:]]+$ ]]
    then
        echo "Error: Name must contain letters only." >&2
        return 1
    elif [[ ! "$name" =~ ^[a-zA-Z[:space:]]{3,50}$ ]]
    then
        echo "Error: Subject name must be 3-50 letters long." >&2
        return 1
    else
        local clean_name="${name// /}"
        local first_char="${clean_name:0:1}"
        local rest="${clean_name//$first_char/}"

        if [[ -z "$rest" ]]
        then
            echo "Error: Name cannot consist of the same letter repeated." >&2
            return 1
        fi
    fi

    return 0
}

is_valid_credits() {
    local credits=$1

    if [[ -z "$credits" ]]
    then
        echo "Error: Credit hours cannot be empty." >&2
        return 1
    elif [[ ! "$credits" =~ ^[1-6]$ ]]
    then
        echo "Error: Credit hours must be an integer between 1 and 6." >&2
        return 1
    fi

    return 0
}

get_subject_code() {
    local subject_code

    while true
    do
        read -r -p "Enter Subject Code (e.g CS101, MATH203): " subject_code

        if is_valid_code "$subject_code"
        then
            subject_code="${subject_code^^}"
            if [[ -f "$SUBJECTS_DIR/${subject_code}.sub" ]]
            then
                echo "Error: Subject code '$subject_code' already exists." >&2
            else
                break
            fi
        fi
    done

    echo "$subject_code"
}

get_existing_subject_code() {
    local subject_code

    while true
    do
        read -r -p "Enter Subject Code: " subject_code
        subject_code="${subject_code^^}"

        if [[ -f "$SUBJECTS_DIR/${subject_code}.sub" ]]
        then
            break
        else
            echo "Error: Subject code '$subject_code' not found." >&2
        fi
    done

    echo "$subject_code"
}

get_subject_name() {
    local subject_name

    while true
    do
        read -r -p "Enter Subject Name: " subject_name

        if is_valid_subject_name "$subject_name"
        then
            break
        fi
    done

    echo "$subject_name"
}

get_subject_credits() {
    local subject_credits

    while true
    do
        read -r -p "Enter Credit Hours (1-6): " subject_credits

        subject_credits="${subject_credits#"${subject_credits%%[!0]*}"}"
        subject_credits="${subject_credits:-1}"

        if is_valid_credits "$subject_credits"
        then
            break
        fi
    done

    echo "$subject_credits"
}

display_subject() {
    local file=$1
    awk -F= '
        /^CODE=/{print "Code    : " $2}
        /^NAME=/{print "Name    : " $2}
        /^CREDITS=/{print "Credits : " $2}
    ' "$file"
}