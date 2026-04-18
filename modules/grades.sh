manage_grades() {
    while true
    do
        clear
        echo "============================"
        echo " Manage Grades "
        echo "============================"
        echo "1) Assign Grade to Student"
        echo "2) Update Existing Grade"
        echo "3) Delete a Grade"
        echo "4) View Grades by Subject"
        echo "5) View Grades by Student"
        echo "b) Back"
        echo ""

        read -r -p "Enter your selection: " choice

        case "$choice" in
            1) assign_grade ;;
            2) update_grade ;;
            3) delete_grade ;;
            4) view_grades_by_subject ;;
            5) view_grades_by_student ;;
            b) echo "Back to main menu..."; sleep 0.5; break ;;
            *) echo "Invalid choice!" ;;
        esac

        echo ""
        read -p "Press Enter to continue..." _
    done
}


assign_grade() {
    clear
    echo "========================="
    echo " Assign Grade to Student "
    echo "========================="

    echo ""
    echo "Avilable Subjects: "
    echo "-------------------"

    show_subjects || return
    echo ""

    local subject_code

    while true
    do
        read -r -p "Enter Subject Code: " subject_code

        subject_code="${subject_code^^}"

        if [[ -f "$SUBJECTS_DIR/${subject_code}.sub" ]]
        then
            break
        else
            echo "Eror: Subject code '$subject_code' not found."
        fi
    done

    echo ""
    echo "Available Students:"
    echo "-------------------"

    show_students || return
    echo ""

    local student_id

    while true
    do
        read -r -p "Enter Student ID: " student_id

        if [[ -f "$STUDENTS_DIR/${student_id}.stu" ]]
        then
            break
        else
            echo "Error: Student ID '$student_id' not found."
        fi
    done

    local file="$GRADES_DIR/${subject_code}.grd"

    if [[ -f "$file" ]]
    then
        if grep -q "^${student_id}|" "$file"
        then
            echo "Error: Student '$student_id' already has a grade in '$subject_code'."
            echo "Use Update Existing Grade instead."
            return
        fi
    fi

    local score

    while true
    do
        read -r -p "Enter Score (0.0 - 100.0): " score

        if is_valid_score "$score"
        then
            break
        fi
    done

    local letter
    letter=$(get_grade "$score")

    echo "${student_id}|${score}|${letter}" >> "$file"

    echo ""
    echo "Grade assigned successfully!"
    echo "Student : $student_id"
    echo "Subject : $subject_code"
    echo "Score   : $score"
    echo "Letter  : $letter"
}


update_grade() {
    clear
    echo "========================"
    echo " Update Existing Grade "
    echo "========================"

    echo ""
    echo "Avialable Subjects:"
    echo "-------------------"

    show_subjects || return
    echo ""

    local subject_code

    while true
    do
        read -r -p "Enter Subject Code: " subject_code
        subject_code="${subject_code^^}"

        if [[ ! -f "$SUBJECTS_DIR/${subject_code}.sub" ]]
        then
            echo "Error: Subject code '$subject_code' not found."
        elif [[ ! -f "$GRADES_DIR/${subject_code}.grd" ]]
        then
            echo "Error : No grades found for subject '$subject_code'."
        else
            break
        fi
    done

    local file="$GRADES_DIR/${subject_code}.grd"

    echo ""
    echo "Current Grades for '$subject_code':"
    echo "-----------------------------------"

    show_grade_file "$file"
    echo ""

    local student_id

    while true
    do
        read -r -p "Enter Student ID: " student_id

        if grep -q "^${student_id}|" "$file"
        then
            break
        else
            echo "Error: No grade found for student '$student_id' in '$subject_code'."
        fi
    done

    local new_score

    while true
    do
        read -r -p "Enter New Score (0.0 - 100.0): " new_score

        if is_valid_score "$new_score"
        then
            break
        fi
    done

    local new_letter
    new_letter=$(get_grade "$new_score")

    sed -i "s/^${student_id}|.*/${student_id}|${new_score}|${new_letter}/" "$file"
    echo ""

    echo "Grade updated successfully!"
    echo "Student : $student_id"
    echo "Subject : $subject_code"
    echo "Score   : $new_score"
    echo "Letter  : $new_letter"

}

delete_grade() {
    clear
    echo "====================="
    echo " Delete a Grade "
    echo "====================="
    echo ""

    echo "Available Subjects:"
    echo "-------------------"

    show_subjects || return
    echo ""

    local subject_code

    while true
    do
        read -r -p "Enter Subject Code: " subject_code
        subject_code="${subject_code^^}"

        if [[ ! -f "$SUBJECTS_DIR/${subject_code}.sub" ]]
        then
            echo "Error: Subject code '$subject_code' not found."
        elif [[ ! -f "$GRADES_DIR/${subject_code}.grd" ]]
        then
            echo "Error: No grades found for subject '$subject_code'."
        else
            break
        fi
    done

    local file="$GRADES_DIR/${subject_code}.grd"

    echo ""
    echo "Current Grades for '$subject_code':"
    echo "-----------------------------------"

    show_grade_file "$file"

    local student_id

    while true
    do
        read -r -p "Enter Student ID: " student_id

        if grep -q "^${student_id}|" "$file"
        then
            break
        else
            echo "Error: No grade found for student '$student_id' in '$subject_code'."
        fi
    done

    echo ""
    echo "Grade to be deleted:"
    echo "--------------------"

    {
        echo "Student ID|Score|Letter"
        grep "^${student_id}|" "$file"
    } | column -t -s '|'
    echo ""

    local confirm

    while true
    do
        read -r -p "Are you sure you want to delete this grade? (y/n): " confirm

        case "$confirm" in
            y|Y)
                sed -i "/^${student_id}|/d" "$file"
                echo "Grade deleted successfully!"
                return ;;
            n|N)
                echo "Operation cancelled."
                return ;;
            *)
                echo "Invalid choice! Please enter y or n." ;;
        esac
    done
}


view_grades_by_subject() {
    clear
    echo "=========================="
    echo " View Grades by Subject "
    echo "=========================="

    echo ""
    echo "Available Subjects: "
    echo "--------------------"

    show_subjects || return

    local subject_code

    while true
    do
        read -r -p "Enter Subject Code: " subject_code
        subject_code="${subject_code^^}"

        if [[ ! -f "$SUBJECTS_DIR/${subject_code}.sub" ]]
        then
            echo "Error: Subject code '$subject_code' not found."
        elif [[ ! -f "$GRADES_DIR/${subject_code}.grd" ]]
        then
            echo "Error: No grades found for subject '$subject_code'."
        else
            break
        fi
    done

    local file="$GRADES_DIR/${subject_code}.grd"

    local subject_name

    subject_name=$(
        awk -F= '
            /^NAME=/{print $2}
        ' "$SUBJECTS_DIR/${subject_code}.sub"
    )

    echo ""
    echo "Grades for '$subject_name' ($subject_code):"
    echo "-------------------------------------------"

    {
        echo "Student ID|Student Name|Score|Letter"

        for s_id in $(awk -F'|' '{print $1}' "$file")
        do
            score=$(grep "^${s_id}" "$file" | awk -F'|' '{print $2}' )
            letter=$(grep "^${s_id}" "$file" | awk -F'|' '{print $3}' )
            student_name=$(
                awk -F= '
                    /^NAME=/{print $2}
                ' "$STUDENTS_DIR/${s_id}.stu" 2>/dev/null
            )
            echo "${s_id}|${student_name:-Unknown}|${score}|${letter}"
        done
    } | column -t -s '|'
}


view_grades_by_student() {
    clear
    echo "==========================="
    echo " View Grades by Student "
    echo "==========================="

    echo ""
    echo "Available Students:"
    echo "-------------------"

    show_students || return
    echo ""

    local student_id

    while true
    do
        read -r -p "Enter Student ID: " student_id

        if [[ -f "$STUDENTS_DIR/${student_id}.stu" ]]
        then
            break
        else
            echo "Error: Student ID '$student_id' not found."
        fi
    done

    local student_name

    student_name=$(
        awk -F= '
            /^NAME=/{print $2}
        ' "$STUDENTS_DIR/${student_id}.stu"
    )

    echo ""
    echo "Grades for '$student_name' (ID: $student_id):"
    echo "---------------------------------------------"

    local found=0

    {
        echo "Subject Code|Subject Name|Score|Letter"

        for grade_file in "$GRADES_DIR"/*.grd
        do
            [[ -f "$grade_file" ]] || continue

            if grep -q "^${student_id}|" "$grade_file"
            then
                found=1
                subject_code="${grade_file##*/}"
                subject_code="${subject_code%.grd}"

                local subject_code
                subject_name=$(
                    awk -F= '
                        /^NAME=/{print $2}
                    ' "$SUBJECTS_DIR/${subject_code}.sub" 2>/dev/null
                )

                local score
                score=$(grep "^${student_id}|" "$grade_file" | awk -F'|' '{print $2}')

                local letter
                letter=$(grep "^${student_id}|" "$grade_file" | awk -F'|' '{print $3}')

                echo "${subject_code}|${subject_name:-Unknown}|${score}|${letter}"
            fi
        done
    } | column -t -s '|'

    if [[ "$found" -eq 0 ]]
    then
        echo "No grades found for this student."
    fi
}