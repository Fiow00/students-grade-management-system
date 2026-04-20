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
    echo ""

    echo "Available Subjects:"
    echo "-------------------"

    show_subjects
    echo ""

    local subject_code
    subject_code=$(get_subject_code)

    local subject_name
    subject_name=$(get_subject_name)

    local subject_credits
    subject_credits=$(get_subject_credits)

    {
        echo "CODE=$subject_code"
        echo "NAME=$subject_name"
        echo "CREDITS=$subject_credits"
    } > "$SUBJECTS_DIR/${subject_code}.sub"

    echo ""
    echo "Subject added successfully!"
    echo "Code    : $subject_code"
    echo "Name    : $subject_name"
    echo "Credits : $subject_credits"
}


list_subjects() {
    clear
    echo "============================"
    echo " List Subjects "
    echo "============================"
    echo ""

    show_subjects || return
    echo ""

    local total
    total=$(ls "$SUBJECTS_DIR"/*.sub 2>/dev/null | wc -l)
    echo "Total Subjects: $total"
}


update_subject() {
    clear
    echo "==========================="
    echo " Update Subject "
    echo "==========================="
    echo ""

    echo "Available Subjects:"
    echo "-------------------"

    show_subjects || return
    echo ""

    local subject_code
    subject_code=$(get_existing_subject_code)

    local file="$SUBJECTS_DIR/${subject_code}.sub"

    echo ""
    echo "Current Data:"

    display_subject "$file"

    while true
    do
        echo ""
        echo "What do you want to update?"
        echo "1) Name"
        echo "2) Credits"
        echo "b) Back"

        read -r -p "Enter your choice: " choice

        case "$choice" in
            1)
                local new_name
                new_name=$(get_subject_name)

                sed -i "s/^NAME=.*/NAME=$new_name/" "$file"
                echo "Name updated successfully!"
                echo ""

                echo "Updated Data:"
                display_subject "$file"
                break ;;

            2)
                local new_credits
                new_credits=$(get_subject_credits)

                sed -i "s/^CREDITS=.*/CREDITS=$new_credits/" "$file"
                echo "Credits updated successfully!"
                echo ""

                echo "Updated Data:"
                display_subject "$file"
                break ;;

            b)
                return ;;

            *)
                echo "Invalid choice! Please enter 1, 2 or b." ;;
        esac
    done
}

delete_subject() {
    clear
    echo "============================"
    echo " Delete Subject "
    echo "============================"
    echo ""

    echo "Available Subjects:"
    echo "-------------------"

    show_subjects || return
    echo ""

    local subject_code
    subject_code=$(get_existing_subject_code)

    local file="$SUBJECTS_DIR/${subject_code}.sub"

    echo ""
    echo "Subject Data:"

    display_subject "$file"
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