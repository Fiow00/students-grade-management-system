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

top_students() {
    clear
    echo "=============================="
    echo " Top Students by GPA Report "
    echo "=============================="

    local temp_file="/tmp/top_students_report.tmp"

    > "$temp_file"

    for student_file in "$STUDENTS_DIR"/*.stu
    do
        [[ -f "$student_file" ]] || continue

        local total_credits=0
        local total_points=0
        local has_grades=false

        local student_id=$(awk -F= '/^ID=/{print $2}' "$student_file")
        local student_name=$(awk -F= '/^NAME=/{print $2}' "$student_file")

        # loop on all grade files
        for grade_file in "$GRADES_DIR"/*.grd
        do
            [[ -f "$grade_file" ]] || continue

            local subject_code=$(basename "$grade_file" .grd)

            local student_grade_line=$(grep "^${student_id}|" "$grade_file")

            if [[ -n "$student_grade_line" ]]
            then
                has_grades=true

                local score
                local letter
                local points
                local subject_file
                local credits

                IFS='|' read -r _ score letter <<< "$student_grade_line"

                subject_file="$SUBJECTS_DIR/${subject_code}.sub"

                if [[ -f "$subject_file" ]]
                then
                    credits=$(awk -F= '/^CREDITS=/{print $2}' "$subject_file")

                    total_credits=$((total_credits + credits))

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

        if [[ "$has_grades" == true && $total_credits -gt 0 ]]
        then
            local gpa
            gpa=$(echo "scale=2; $total_points / $total_credits" | bc)

            echo "$student_id|$student_name|$gpa" >> "$temp_file"
        fi
    done

    echo ""
    echo "Top Students by GPA"
    echo "------------------------------------------------------------"

    awk 'BEGIN {
        printf "%-12s %-25s %-10s\n", "Student ID", "Name", "GPA"
    }'

    echo "------------------------------------------------------------"

    sort -t'|' -k3,3nr "$temp_file" | head -5 | \
    awk -F'|' '{
        printf "%-12s %-25s %-10s\n", $1, $2, $3
    }'

    rm -f "$temp_file"
} 

failing_students() {
    clear
    echo "=============================="
    echo " Failing Students Report "
    echo "=============================="

    local temp_file="/tmp/failing_students_report.tmp"

    > "$temp_file"

    for student_file in "$STUDENTS_DIR"/*.stu
    do
        [[ -f "$student_file" ]] || continue

        local student_id=$(awk -F= '/^ID=/{print $2}' "$student_file")
        local student_name=$(awk -F= '/^NAME=/{print $2}' "$student_file")

       
        for grade_file in "$GRADES_DIR"/*.grd
        do
            [[ -f "$grade_file" ]] || continue

            local subject_code=$(basename "$grade_file" .grd)

            local student_grade_line=$(grep "^${student_id}|" "$grade_file")

            if [[ -n "$student_grade_line" ]]
            then
                local score
                local letter

                IFS='|' read -r _ score letter <<< "$student_grade_line"

                if [[ "$letter" == "F" ]]
                then
                    echo "$student_id|$student_name|$subject_code" >> "$temp_file"
                fi
            fi
        done
    done

    echo ""
    echo "Failing Students"
    echo "------------------------------------------------------------"

    awk 'BEGIN {
        printf "%-12s %-25s %-15s\n", "Student ID", "Name", "Subject Code"
    }'

    echo "------------------------------------------------------------"

    sort -t'|' -k1,1 "$temp_file" | \
    awk -F'|' '{
        printf "%-12s %-25s %-15s\n", $1, $2, $3
    }'

    rm -f "$temp_file"
}

full_grade_matrix() {
    clear
    echo "=============================="
    echo " Full Grade Matrix Report "
    echo "=============================="

    local temp_file="/tmp/full_grade_matrix_report.tmp"

    > "$temp_file"

    for student_file in "$STUDENTS_DIR"/*.stu
    do
        [[ -f "$student_file" ]] || continue

        local student_id=$(awk -F= '/^ID=/{print $2}' "$student_file")
        local student_name=$(awk -F= '/^NAME=/{print $2}' "$student_file")

        echo -n "$student_id|$student_name" >> "$temp_file"

        for grade_file in "$GRADES_DIR"/*.grd
        do
            [[ -f "$grade_file" ]] || continue

            local student_grade_line=$(grep "^${student_id}|" "$grade_file")

            if [[ -n "$student_grade_line" ]]
            then
                local score
                local letter

                IFS='|' read -r _ score letter <<< "$student_grade_line"

                echo -n "|$letter" >> "$temp_file"
            else
                echo -n "|-" >> "$temp_file"
            fi
        done

        echo "" >> "$temp_file"
    done

    echo ""
    echo "Full Grade Matrix"
    echo "------------------------------------------------------------"
    echo "Student ID    Name                 Grades"
    echo "------------------------------------------------------------"

    sort -t'|' -k1,1 "$temp_file" | \
    awk -F'|' '{
        printf "%-12s %-20s %s\n", $1, $2, substr($0, index($0,$3)) 
    }'

    rm -f "$temp_file"
}