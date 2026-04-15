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
