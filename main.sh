#!/bin/bash

trap 'echo " Use q to exit."' INT

manage_students() {
    echo "Manage students is chosen"
}

manage_subjects() {
    echo "Manage subjects is chosen"
}

manage_grades() {
    echo "Manage grades is chosen"
}

while true
do
    clear
    echo "============================"
    echo " Student Grade Management "
    echo "============================"
    echo "1) Manage Students"
    echo "2) Manage Subjects"
    echo "3) Manage Grades"
    echo "q) Exit"
    echo ""

    read -p "Enter your selection: " answer

    case "$answer" in
        1) manage_students ;;
        2) manage_subjects ;;
        3) manage_grades ;;
        q) echo "Exiting..."; exit 0 ;;
        *) echo "Invalid choice!" ;;
    esac

    echo ""
    read -p "Press Enter to continue..." _
done
