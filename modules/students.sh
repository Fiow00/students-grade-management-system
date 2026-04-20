manage_students() {
    while true
    do
        clear
        echo "============================"
        echo " Manage Students "
        echo "============================"
        echo "1) Add Student"
        echo "2) List Students"
        echo "3) Update Student"
        echo "4) Delete Student"
        echo "b) Back"
        echo ""

        read -r -p "Enter your selection: " choice

        case "$choice" in
            1) add_student ;;
            2) list_students ;;
            3) update_student ;;
            4) delete_student ;;
            b) echo "Back to main menu..."; sleep 0.5; break ;;
            *) echo "Invalid choice!" ;;
        esac

        echo ""
        read -p "Press Enter to continue..." _
    done
}

add_student() {
    clear
    echo "=========================="
    echo " Add Student "
    echo "=========================="
    echo ""

    echo "Available Students:"
    echo "-------------------"

    show_students
    echo ""

    local student_id
    student_id=$(get_student_id)

    local student_name
    student_name=$(get_student_name)

    local student_email
    student_email=$(get_student_email)

    local student_year
    student_year=$(get_student_year)

    {
        echo "ID=$student_id"
        echo "NAME=$student_name"
        echo "EMAIL=$student_email"
        echo "YEAR=$student_year"
    } > "$STUDENTS_DIR/${student_id}.stu"

    echo ""
    echo "Student added successfully!"
    echo "ID    : $student_id"
    echo "Name  : $student_name"
    echo "Email : $student_email"
    echo "Year  : $student_year"
}

list_students() {
    clear
    echo "===================================="
    echo " List Students "
    echo "===================================="
    echo ""

    show_students || return
    echo ""

    local total
    total=$(ls "$STUDENTS_DIR"/*.stu 2>/dev/null | wc -l)
    echo "Total Students: $total"
}

update_student() {
    clear
    echo "=========================="
    echo " Update Student "
    echo "=========================="
    echo ""

    echo "Available Students:"
    echo "-------------------"

    show_students || return
    echo ""

    local student_id
    student_id=$(get_existing_student_id)

    local file="$STUDENTS_DIR/${student_id}.stu"

    echo ""
    echo "Current Data:"
    display_student "$file"

    while true
    do
        echo ""
        echo "What do you want to update?"
        echo "1) Name"
        echo "2) Email"
        echo "3) Year"
        echo "b) Back"

        read -r -p "Enter your choice: " choice

        case "$choice" in
            1)
                local new_name
                new_name=$(get_student_name)

                sed -i "s/^NAME=.*/NAME=$new_name/" "$file"
                echo "Name updated successfully!"
                echo ""

                echo "Updated Data:"
                display_student "$file"
                break ;;

            2)
                local new_email
                new_email=$(get_student_email "$student_id")

                sed -i "s/^EMAIL=.*/EMAIL=$new_email/" "$file"
                echo "Email updated successfully!"
                echo ""

                echo "Updated Data:"
                display_student "$file"
                break ;;

            3)
                local new_year
                new_year=$(get_student_year)

                sed -i "s/^YEAR=.*/YEAR=$new_year/" "$file"
                echo "Year updated successfully!"
                echo ""

                echo "Updated Data:"
                display_student "$file"
                break ;;

            b)
                return ;;

            *)
                echo "Invalid choice!" ;;
        esac
    done
}


delete_student() {
    clear
    echo "=========================="
    echo " Delete Student "
    echo "=========================="
    echo ""

    echo "Available Students:"
    echo "-------------------"

    show_students || return
    echo ""

    local student_id
    student_id=$(get_existing_student_id)

    local file="$STUDENTS_DIR/${student_id}.stu"

    echo ""
    echo "Student Data:"
    display_student "$file"

    echo ""
    local confirm

    while true
    do
        read -r -p "Are you sure you want to delete this student? (y/n): " confirm

        case "$confirm" in
            y|Y)
                rm "$file"

                local deleted_grades=0

                for grade_file in "$GRADES_DIR"/*.grd
                do
                    [[ -f "$grade_file" ]] || continue

                    if grep -q "^${student_id}|" "$grade_file"
                    then
                        sed -i "/^${student_id}|/d" "$grade_file"
                        deleted_grades=$((deleted_grades + 1))
                    fi
                done

                echo "Student deleted successfully!"

                if [[ "$deleted_grades" -gt 0 ]]
                then
                    echo "($deleted_grades grade records also removed)"
                fi
                return ;;
            n|N)
                echo "Operation cancelled."
                return ;;
            *)
                echo "Invalid choice! Please enter y or n." ;;
        esac
    done
}