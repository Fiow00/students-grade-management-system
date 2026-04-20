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
        echo "Error: Student ID cannot be empty." >&2
        return 1
    elif [[ ! "$id" =~ ^[0-9]{1,10}$ ]]
    then
        echo "Error: ID must be numeric and up to 10 digits." >&2
        return 1
    elif [[ "$id" =~ ^0+$ ]]
    then
        echo "Error: Student Id cannot be zero." >&2
        return 1
    fi

    return 0
}

valid_name() {
    local name=$1

    if [[ -z "$name" ]]
    then
        echo "Error: Name cannot be empty." >&2
        return 1
    elif [[ ! "$name" =~ ^[a-zA-Z[:space:]]+$ ]]
    then
        echo "Error: Enter a valid name (letters only)." >&2
        return 1
    elif [[ ! "$name" =~ ^[a-zA-Z[:space:]]{3,50}$ ]]
    then
        echo "Error: Name must be 3-50 letters long." >&2
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

valid_email() {
    local email=$1

    if [[ -z "$email" ]]
    then
        echo "Error: Email cannot be empty." >&2
        return 1
    elif [[ "$email" == *".."* ]]
    then
        echo "Error: Email cannot contain consecutive dots." >&2
        return 1
    elif [[ ! "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]
    then
        echo "Error: Invalid email. Must be in student@domain.ext format." >&2
        return 1
    fi

    return 0
}

valid_year() {
    local year=$1

    if [[ -z "$year" ]]
    then
        echo "Error: Academic year cannot be empty." >&2
        return 1
    elif [[ ! "$year" =~ ^[1-6]$ ]]
    then
        echo "Error: Academic year must be an integer between 1 and 6." >&2
        return 1
    fi

    return 0
}

get_student_id() {
    local student_id

    while true
    do
        read -r -p "Enter Student ID (numeric, max 10 digits): " student_id

        if valid_id "$student_id"
        then
            if [[ -f "$STUDENTS_DIR/${student_id}.stu" ]]
            then
                echo "Error: Student ID '$student_id' already exists." >&2
            else
                break
            fi
        fi
    done

    echo "$student_id"
}

get_existing_student_id() {
    local student_id

    while true
    do
        read -r -p "Enter Student ID: " student_id

        if [[ -f "$STUDENTS_DIR/${student_id}.stu" ]]
        then
            break
        else
            echo "Error: Student ID '$student_id' not found." >&2
        fi
    done

    echo "$student_id"
}

get_student_name() {
    local student_name

    while true
    do
        read -r -p "Enter student name: " student_name

        if valid_name "$student_name"
        then
            break
        fi
    done

    echo "$student_name"
}

get_student_email() {
    local exclude_id=${1:-""}
    local student_email

    while true
    do
        read -r -p "Enter student email: " student_email

        student_email="$(echo "$student_email" | xargs)"
        student_email="${student_email,,}"

        if valid_email "$student_email"
        then
            local escaped_email
            escaped_email=$(echo "$student_email" | sed 's/[.]/\\./g')

            if grep -qr "^EMAIL=${escaped_email}$" "$STUDENTS_DIR" --exclude="${exclude_id}.stu"
            then
                echo "Error: Email '$student_email' is already in use." >&2
            else
                break
            fi
        fi
    done

    echo "$student_email"
}

get_student_year() {
    local student_year

    while true
    do
        read -r -p "Enter student's academic year (1-6): " student_year

        student_year="${student_year#"${student_year%%[!0]*}"}"
        student_year="${student_year:-1}"

        if valid_year "$student_year"
        then
            break
        fi
    done

    echo "$student_year"
}

display_student() {
    local file=$1
    awk -F= '
        /^ID=/{print "ID    : " $2}
        /^NAME=/{print "Name  : " $2}
        /^EMAIL=/{print "Email : " $2}
        /^YEAR=/{print "Year  : " $2}
    ' "$file"
}