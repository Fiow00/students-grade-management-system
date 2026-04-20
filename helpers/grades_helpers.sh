get_grade() {
    local score=$1
    awk -v score="$score" 'BEGIN {
        if (score >= 90) print "A+"
        else if (score >= 85) print "A"
        else if (score >= 80) print "A-"
        else if (score >= 75) print "B+"
        else if (score >= 70) print "B"
        else if (score >= 65) print "B-"
        else if (score >= 60) print "C+"
        else if (score >= 55) print "C"
        else if (score >= 50) print "C-"
        else if (score >= 45) print "D"
        else print "F"
    }'
}

is_valid_score() {
    local score=$1

    if [[ -z "$score" ]]
    then
        echo "Error: Score cannot be empty." >&2
        return 1
    elif [[ ! "$score" =~ ^[0-9]+(\.[0-9]+)?$ ]]
    then
        echo "Error: Score must be a number (e.g 85 or 92.5)." >&2
        return 1
    fi

    local valid_range
    valid_range=$(awk -v s="$score" 'BEGIN {
        if (s >= 0 && s <= 100)
            print "yes"
        else
            print "no"
    }')

    if [[ "$valid_range" != "yes" ]]
    then
        echo "Error: Score must be between 0.0 and 100.0." >&2
        return 1
    fi

    return 0
}

show_grade_file() {
    local file=$1

    if [[ ! -f "$file" ]] || [[ ! -s "$file" ]]
    then
        echo "No grades found."
        return 1
    fi

    {
        echo "Student ID|Score|Letter"
        awk -F'|' '{ print $1 "|" $2 "|" $3 }' "$file"
    } | column -t -s '|'
}