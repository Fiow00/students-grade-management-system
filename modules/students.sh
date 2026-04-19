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
    echo "Available Students: "
    echo "--------------------"

    show_students || return
    echo ""

    # get student id
    local student_id

    while true
    do
        read -r -p "Enter Student ID (numeric, max 10 digits): " student_id

        if valid_id "$student_id"
        then
            if [[ -f "$STUDENTS_DIR/${student_id}.stu" ]]
            then
                echo "Error: Student ID '$student_id' already exists."
            else
                break
            fi
        fi
    done

    # get student name
    local student_name

    while true
    do
        read -r -p "Enter student name: " student_name

        if valid_name "$student_name"
        then
            break
        fi
    done

    # get student email
    local student_email

    while true
    do
        read -r -p "Enter student email: " student_email

        student_email="${student_email,,}"

        if valid_email "$student_email"
        then
            if grep -qrF "EMAIL=$student_email" "$STUDENTS_DIR"
            then
                echo "Error: Email '$student_email' is alread in use."
            else
                break
            fi
        fi
    done

    local student_year
    while true
    do
        read -r -p "Enter student's academic year(1-6): " student_year

        if valid_year "$student_year"
        then
            break
        fi
    done

    {
        echo "ID=$student_id"
        echo "NAME=$student_name"
        echo "EMAIL=$student_email"
        echo "YEAR=$student_year"
    } > "$STUDENTS_DIR/${student_id}.stu"

    echo ""
    echo "Student '$student_name' (ID: $student_id) added successfully!"
}


list_students() {
    clear
    echo "===================================="
    echo " List Students "
    echo "===================================="

    show_students || return

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

    local file="$STUDENTS_DIR/${student_id}.stu"

    echo ""
    echo "Current Data:"
    awk -F= '
        /^ID=/{print "ID    : " $2}
        /^NAME=/{print "Name  : " $2}
        /^EMAIL=/{print "Email : " $2}
        /^YEAR=/{print "Year  : " $2}
    ' "$file"

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
                while true
                do
                    read -r -p "Enter new name: " new_name

                    if valid_name "$new_name"
                    then
                        break
                    fi
                done

                sed -i "s/^NAME=.*/NAME=$new_name/" "$file"
                echo "Name updated successfully!"
                break ;;

            2)
                local new_email
                while true
                do
                    read -r -p "Enter new email: " new_email

                    new_email="$(echo "$new_email" | xargs)"
                    new_email="${new_email,,}"

                    if valid_email "$new_email"
                    then
                        if grep -qrF "EMAIL=$new_email" "$STUDENTS_DIR"
                        then
                            echo "Error: Email already exists."
                        else
                            break
                        fi
                    fi
                done

                sed -i "s/^EMAIL=.*/EMAIL=$new_email/" "$file"
                echo "Email updated successfully!"
                break ;;

            3)
                local new_year
                while true
                do
                    read -r -p "Enter new year (1-6): " new_year

                    if valid_year "$new_year"
                    then
                        break
                    fi
                done

                sed -i "s/^YEAR=.*/YEAR=$new_year/" "$file"
                echo "Year updated successfully!"
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

    local file="$STUDENTS_DIR/${student_id}.stu"

    echo ""
    echo "Student Data:"
    awk -F= '
        /^ID=/{print "ID    : " $2}
        /^NAME=/{print "Name  : " $2}
        /^EMAIL=/{print "Email : " $2}
        /^YEAR=/{print "Year  : " $2}
    ' "$file"

    echo ""
    local confirm

    while true
    do
        read -r -p "Are you sure you want to delete this student? (y/n): " confirm

        case "$confirm" in
            y|Y)
                rm "$file"

                for grade_file in "$GRADES_DIR"/*.grd
                do
                    [[ -f "$grade_file" ]] || continue
                    sed -i "/^${student_id}|/d" "$grade_file"
                done

                echo "Student deleted successfully!"
                return ;;
            n|N)
                echo "Operation cancelled."
                return ;;
            *)
                echo "Invalid choice! Please enter y or n." ;;
        esac
    done
}