show_students() {
    if [[ -z "$(ls -A "$STUDENTS_DIR")" ]]
    then
        echo "No students found."
        return 1
    fi

    {
        echo "ID|Name|Email|Year"
        for student in "$STUDENTS_DIR"/*.stu
        do
            awk -F= '
                /^ID=/    {id=$2}
                /^NAME=/  {name=$2}
                /^EMAIL=/ {email=$2}
                /^YEAR=/  {year=$2}
                END { print id "|" name "|" email "|" year }
            ' "$student"
        done
    } | column -t -s '|'
}

valid_id() {
    local id=$1

    if [[ -z "$id" ]]
    then
        echo "Error: Student ID cannot be empty."
        return 1
    elif [[ ! "$id" =~ ^[0-9]{1,10}$ ]]
    then
        echo "Error: ID must be numeric and up to 10 digits."
        return 1
    elif [[ "$id" -eq 0 ]]
    then
        echo "Error: Student Id cannot be zero."
        return 1
    fi

    return 0
}

valid_name() {
    local name=$1

    if [[ -z "$name" ]]
    then
        echo "Error: Name cannot be empty."
        return 1
    elif [[ ! "$name" =~ ^[a-zA-Z[:space:]]+$ ]]
    then
        echo "Error: Enter a valid name (letters only)."
        return 1
    elif [[ ! "$name" =~ ^[a-zA-Z[:space:]]{3,50}$ ]]
    then
        echo "Error: Name must be 3-50 letters long."
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

valid_email() {
    local email=$1

    if [[ -z "$email" ]]
    then
        echo "Error: Email cannot be empty."
        return 1
    elif [[ "$email" == *".."* ]]
    then
        echo "Error: Email cannot contain consecutive dots."
        return 1
    elif [[ ! "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]
    then
        echo "Error: Invalid email. Must be in student@domain.ext format."
        return 1
    fi

    return 0
}

valid_year() {
    local year=$1

    if [[ -z "$year" ]]
    then
        echo "Error: Academic year cannot be empty."
        return 1
    elif [[ ! "$year" =~ ^[1-6]$ ]]
    then
        echo "Error: Academic year must be an integer between 1 and 6."
        return 1
    fi

    return 0
}