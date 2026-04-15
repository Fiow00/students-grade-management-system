#!/bin/bash

source modules/students.sh
source modules/subjects.sh
source modules/grades.sh

trap 'echo -e "\nUse q to exit."' INT

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

    read -r -p "Enter your selection: " choice

    case "$choice" in
        1) 
            echo "Opening Students Module..."
            sleep 0.5
            manage_students ;;
        2) 
            echo "Opening Subjects Module..."
            sleep 0.5
            manage_subjects ;;
        3) 
            echo "Opening Grades Module..."
            sleep 0.5
            manage_grades ;;
        q) echo "Exiting..."; sleep 0.5; exit 0 ;;
        "") echo "Please enter a choice!" ;;
        *) echo "Invalid choice!" ;;
    esac

    echo ""
    read -p "Press Enter to continue..." _
done
