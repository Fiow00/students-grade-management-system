# =========================================
# Students Module
# Handles all student-related operations:
# - Add
# - List
# - Update
# - Delete
# =========================================

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

    # get student id
    local student_id

    while true
    do
        read -r -p "Enter Student ID (numeric, max 10 digits): " student_id

        if [[ "$student_id" =~ ^[0-9]{1,10}$ ]]
        then
            if [[ -f "$STUDENTS_DIR/${student_id}.stu" ]]
            then
                echo "Error: Student ID '$student_id' already exists."
            else
                break
            fi
        else
            echo "Error: ID must be numeric and up to 10 digits."
        fi
    done

    # get student name
    local student_name

    while true
    do
        read -r -p "Enter student name: " student_name
        if [[ -z "$student_name" ]]
        then
            echo "Error: Student's name cannot be empty"
        elif [[ ! "$student_name" =~ ^[a-zA-Z[:space:]]+$ ]]
        then
            echo "Error: Name must contain letters only"
        else
            break
        fi
    done

    # get student email
    local student_email

    while true
    do
        read -r -p "Enter student email: " student_email
        if [[ "$student_email" =~ ^[^@]+@[^@]+\.[^@]+$ ]]
        then
            if grep -qri "^EMAIL=${student_email}$" "$STUDENTS_DIR"
            then
                echo "Error: Email '$student_email' is already in use."
            else
                break
            fi
        else
            echo "Error: Invalid email. Must be in student@domain.ext format."
        fi
    done

    local student_year
    while true
    do
        read -r -p "Enter student's academic year(1-6): " student_year
        if [[ "$student_year" =~ ^[1-6]$ ]]
        then
            break
        else
            echo "Error: Academic year must be an integer between 1 and 6."
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

    if [[ -z "$(ls -A "$STUDENTS_DIR")" ]]
    then
        echo "No students found."
        return
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
            
                END {
                    print id "|" name "|" email "|" year
                }
            ' "$student"
        done
    } | column -t -s '|'
}

update_student() {
    clear
    echo "=========================="
    echo " Update Student "
    echo "=========================="

    local student_id

    read -r -p "Enter Student ID: " student_id

    local file="$STUDENTS_DIR/${student_id}.stu"

    if [[ ! -f "$file" ]]
    then
        echo "Error: Student not found!"
        return
    fi

    echo ""
    echo "Current Data:"
    cat "$file"

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
                if [[ -z "$new_name" ]]
                then
                    echo "Error: Name cannot be empty"
                elif [[ ! "$new_name" =~ ^[a-zA-Z[:space:]]+$ ]]
                then
                    echo "Error: Name must contain letters only"
                else
                    break
                fi
            done

            sed -i "s/^NAME=.*/NAME=$new_name/" "$file"
            echo "Name updated successfully!" ;;
        
        2)
            local new_email
            while true
            do
                read -r -p "Enter new email: " new_email
                if [[ "$new_email" =~ ^[^@]+@[^@]+\.[^@]+$ ]]
                then
                    if grep -qri "^Email=${new_email}$" "$STUDENTS_DIR"
                    then
                        echo "Error: Email already exists."
                    else
                        break
                    fi
                else
                    echo "Invalid email format."
                fi
            done

            sed -i "s/^EMAIL=.*/EMAIL=$new_email/" "$file"
            echo "Email updated successfully!" ;;
        
        3)
            local new_year

            while true
            do
                read -r -p "Enter new year (1-6): " new_year
                if [[ "$new_year" =~ ^[1-6]$ ]]
                then
                    break
                else
                    echo "Error: Academic year must be an integer between 1 and 6."
                fi
            done

            sed -i "s/^YEAR=.*/YEAR=$new_year/" "$file"
            echo "Year updated successfully!" ;;

        b)
            return ;;

        *)
            echo "Invalid choice!" ;;
    esac
}


delete_student() {
    clear
    echo "=========================="
    echo " Delete Student "
    echo "=========================="

    local student_id

    read -r -p "Enter Student ID: " student_id

    local file="$STUDENTS_DIR/${student_id}.stu"

    if [[ ! -f "$file" ]]
    then
        echo "Error: Student not found!"
        return
    fi

    echo ""
    echo "Student Data:"
    cat "$file"

    echo ""
    read -r -p "Are you sure you want to delete this student? (y/n): " confirm

    case "$confirm" in
        y|Y)
            rm "$file"
            echo "Student deleted successfully!" ;;
        n|N)
            echo "Operation cancelled." ;;
        *)
            echo "Invalid choice!" ;;
    esac
}