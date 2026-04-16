manage_subjects() {
    while true
    do
        clear
        echo "============================"
        echo " Manage Subjects "
        echo "============================"
        echo "1) Add Subject"
        echo "2) List Subjects"
        echo "3) Update Subject"
        echo "4) Delete Subject"
        echo "b) Back"
        echo ""

        read -r -p "Enter your selection: " choice

        case "$choice" in
            1) add_subject ;;
            2) list_subjects ;;
            3) update_subject ;;
            4) delete_subject ;;
            b) echo "Back to main menu..."; sleep 0.5; break ;;
            *) echo "Invalid choice!" ;;
        esac

        echo ""
        read -p "Press Enter to continue..." _
    done
}


add_subject() {
    clear
    echo "=========================="
    echo " Add Subject "
    echo "=========================="

    local subject_code

    # get subject code
    while true
    do
        read -r -p "Enter Subject Code (e.g CS101, MATH203): " subject_code

        if [[ "$subject_code" =~ ^[a-zA-Z]{2,5}[0-9]{2,4}$ ]]
        then
            if [[ -f "$SUBJECTS_DIR/${subject_code}.sub" ]]
            then
                echo "Error: Subject code '$subject_code' already exists."
            else
                break
            fi
        else
            echo "Error: Code must be 2-5 letters followed by 2-4 digits (e.g. CS101)."
        fi
    done

    # get subject code
    local subject_name

    while true
    do
        read -r -p "Enter Subject Name: " subject_name

        if [[ -z "$subject_name" ]]
        then
            echo "Error: Subject name cannot be empty."
        elif [[ ! "$subject_name" =~ ^[a-zA-Z[:space:]]+$ ]]
        then
            echo "Error: Name must contain letters only."
        else
            break
        fi
    done

    # get credit hours
    local subject_credits

    while true
    do
        read -r -p "Enter Credit Hours (1-6): " subject_credits

        if [[ "$subject_credits" =~ ^[1-6]$ ]]
        then
            break
        else
            echo "Error: Credit hours must be an integer between 1 and 6."
        fi
    done

    {
        echo "CODE=$subject_code"
        echo "NAME=$subject_name"
        echo "CREDITS=$subject_credits"
    } > "$SUBJECTS_DIR/${subject_code}.sub"

    echo ""
    echo "Subject '$subject_name' ($subject_code) added successfully!"

}


list_subjects() {
    clear
    echo "============================"
    echo "      List Subjects         "
    echo "============================"

    if [[ -z "$(ls -A "$SUBJECTS_DIR")" ]]
    then
        echo "No subjects found."
        return
    fi

    {
        echo "Code|Name|Credits"

        for subject in "$SUBJECTS_DIR"/*.sub
        do
            awk -F= '
                /^CODE=/    {code=$2}
                /^NAME=/    {name=$2}
                /^CREDITS=/ {credits=$2}

                END {
                    print code "|" name "|" credits
                }
            ' "$subject"
        done
    } | column -t -s '|'
}


update_subject() {
    clear
    echo "==========================="
    echo " Update Subject "
    echo "==========================="

    local subject_code

    while true
    do
        read -r -p "Enter Subject Code: " subject_code

        if [[ -f "$SUBJECTS_DIR/${subject_code}.sub" ]]
        then
            break
        else
            echo "Error: Subject code '$subject_code' not found."
        fi
    done

    local file="$SUBJECTS_DIR/${subject_code}.sub"

    echo ""
    echo "Current Data: "
    awk -F= '
        /^CODE=/{
            print "Code    : " $2
        }
        /^NAME=/{
            print "Name    : " $2
        }
        /^CREDITS=/{
            print "Dredits : " $2
        }
    ' "$file"

    echo ""
    echo "What do you want to update? "
    echo "1) Name"
    echo "2) Credits"
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
                    echo "Error: Name cannot be empty."
                elif [[ ! "$new_name" =~ ^[a-zA-Z[:space:]]+$ ]]
                then
                    echo "Error: Name must contains letters only."
                else
                    break
                fi
            done

            sed -i "s/^NAME=.*/NAME=$new_name/" "file"
            echo "Name updated successfully!" ;;
        
        2)
            local new_credits
            while true
            do
                read -r -p "Enter new credit hours (1-6): " new_credits

                if [[ "$new_credits" =~ ^[1-6]$ ]]
                then
                    break
                else
                    echo "Error: Credit hours must be an integer between 1 and 6."
                fi
            done

            sed -i "s/^CREDITS=.*/CREDITS=$new_credits/" "$file"
            echo "Credits updated successfully!" ;;

        b)
            return ;;

        *)
            echo "Invalid choice!" ;;
    esac

}

delete_subject() {
    clear
    echo "============================"
    echo " Delete Subject "
    echo "============================"

    local subject_code

    while true
    do
        read -r -p "Enter Subject Code: " subject_code

        if [[ -f "$SUBJECTS_DIR/${subject_code}.sub" ]]
        then
            break
        else
            echo "Error: Subject code '$subject_code' not found."
        fi
    done

    local file="$SUBJECTS_DIR/${subject_code}.sub"

    echo ""
    echo "Subject Data: "
    awk -F= '
        /^CODE=/{
            print "Code    : " $2
        }
        /^NAME=/{
            print "Name    : " $2
        }
        /^CREDITS=/{
            print "Credits : " $2
        }
    ' "$file"

    echo ""

    local confirm

    while true
    do
        read -r -p "Are you sure you want to delete this subject? (y/n): " confirm
        case "$confirm" in
            y|Y)
                rm "$file"

                if [[ -f "$GRADES_DIR/${subject_code}.grd" ]]
                then
                    rm "$GRADES_DIR/${subject_code}.grd"
                    echo "Related grade file also deleted."
                fi
                echo "Subject deleted successfully!"
                return ;;

            n|N)
                echo "Operation cancelled."
                return ;;

            *)
                echo "Invalid choice! Please enter y or n." ;;
        esac
    done

}