manage_reports() { 
    while true 
    do clear 
    echo "============================" 
    echo " Manage Reports " 
    echo "============================" 
    echo "1) Student Transcript + GPA Report" 
    echo "2) Subject Statistics Report" 
    echo "3) Top Students by GPA Report" 
    echo "4) Failing Students Report " 
    echo "5) Full Grade Matrix Report" 
    echo "b) Back" 
    echo "" 
    read -r -p "Enter your selection: " choice 

    case "$choice" in 
        1) student_transcript ;; 
        2) subject_statistics ;; 
        3) top_students ;; 
        4) failing_students ;; 
        5) full_grade_matrix ;; 
        b) echo "Back to main menu..."; sleep 0.5; break ;; 
        *) echo "Invalid choice!" ;; 
    esac 
    echo "" 
    read -p "Press Enter to continue..." _ 
done }

student_transcript() {
    clear
    echo "=============================="
    echo " Student Transcript + GPA Report "
    echo "=============================="

    local student_id

    # get student id
    while true
    do
        read -r -p "Enter Student ID: " student_id

        if [[ -f "$STUDENTS_DIR/${student_id}.stu" ]]
        then
            break
        else
            echo "Error: Student ID '$student_id' does not exist."
        fi
    done

    local student_file="$STUDENTS_DIR/${student_id}.stu"
    local student_name
    local total_credits=0
    local total_points=0
    local has_grades=false

    # get student name
    student_name=$(awk -F= '/^NAME=/{print $2}' "$student_file")

    echo ""
    echo "Transcript for $student_name (ID: $student_id)"
    echo "------------------------------------------------------------"
    printf "%-10s %-20s %-10s %-10s\n" "Code" "Name" "Credits" "Grade"
    echo "------------------------------------------------------------"

    # loop on all grade files
    for grade_file in "$GRADES_DIR"/*.grd
    do
        [[ -f "$grade_file" ]] || continue

        local subject_code
        local student_grade_line

        subject_code=$(basename "$grade_file" .grd)

        # search for current student grade
        student_grade_line=$(grep "^${student_id}|" "$grade_file")

        if [[ -n "$student_grade_line" ]]
        then
            has_grades=true

            local score
            local letter
            local points
            local subject_file
            local subject_name
            local credits

            IFS='|' read -r _ score letter <<< "$student_grade_line"

            subject_file="$SUBJECTS_DIR/${subject_code}.sub"

            if [[ -f "$subject_file" ]]
            then
                # get subject data
                subject_name=$(awk -F= '/^NAME=/{print $2}' "$subject_file")
                credits=$(awk -F= '/^CREDITS=/{print $2}' "$subject_file")

                printf "%-10s %-20s %-10s %-10s\n" \
                    "$subject_code" "$subject_name" "$credits" "$letter"

                total_credits=$((total_credits + credits))

                # convert letter to gpa points
                case "$letter" in
                    A+) points=4 ;;
                    A)  points=4 ;;
                    A-) points=3.7 ;;
                    B+) points=3.3 ;;
                    B)  points=3 ;;
                    B-) points=2.7 ;;
                    C+) points=2.3 ;;
                    C)  points=2 ;;
                    C-) points=1.7 ;;
                    D)  points=1 ;;
                    F)  points=0 ;;
                    *)  points=0 ;;
                esac

                total_points=$(echo "$total_points + ($points * $credits)" | bc)
            fi
        fi
    done

    echo "------------------------------------------------------------"

    if [[ "$has_grades" == false ]]
    then
        echo "No grades found for this student."
        return
    fi

    local gpa
    gpa=$(echo "scale=2; $total_points / $total_credits" | bc)

    echo "Total Credits : $total_credits"
    echo "Final GPA     : $gpa"
}

subject_statistics() {
    clear
    echo "=============================="
    echo " Subject Statistics Report "
    echo "=============================="

    local subject_code

   
    while true
    do
        read -r -p "Enter Subject Code: " subject_code

        if [[ -f "$SUBJECTS_DIR/${subject_code}.sub" ]]
        then
            break
        else
            echo "Error: Subject Code '$subject_code' does not exist."
        fi
    done

    local subject_file="$SUBJECTS_DIR/${subject_code}.sub"
    local grade_file="$GRADES_DIR/${subject_code}.grd"
    local subject_name
    local total_students=0

    
    declare -A grade_counts

    
    for grade in A+ A A- B+ B B- C+ C C- D F
    do
        grade_counts["$grade"]=0
    done

    
    subject_name=$(awk -F= '/^NAME=/{print $2}' "$subject_file")

    echo ""
    echo "Statistics for $subject_name (Code: $subject_code)"
    echo "------------------------------------------------------------"
    printf "%-10s %-20s\n" "Grade" "Count"
    echo "------------------------------------------------------------"

    
    if [[ ! -f "$grade_file" ]]
    then
        echo "No grades found for this subject."
        return
    fi

    
    while IFS='|' read -r student_id score letter
    do
        grade_counts["$letter"]=$((grade_counts["$letter"] + 1))
        total_students=$((total_students + 1))
    done < "$grade_file"

   
    for grade in A+ A A- B+ B B- C+ C C- D F
    do
        printf "%-10s %-20s\n" "$grade" "${grade_counts[$grade]}"
    done

    echo "------------------------------------------------------------"
    echo "Total Students : $total_students"
}