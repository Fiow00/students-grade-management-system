#!/bin/bash

DATA_DIR="sgms_data"
STUDENTS_DIR="$DATA_DIR/students"
SUBJECTS_DIR="$DATA_DIR/subjects"
GRADES_DIR="$DATA_DIR/grades"

mkdir -p "$STUDENTS_DIR" "$SUBJECTS_DIR" "$GRADES_DIR"

source modules/students.sh || { echo "Error loading students module"; exit 1; }
source modules/subjects.sh || { echo "Error loading subjects module"; exit 1; }
source modules/grades.sh || { echo "Error loading grades module"; exit 1; }
source modules/reports.sh || { echo "Error loading reports module"; exit 1; }

while true
do
    clear
    echo "============================"
    echo " Student Grade Management "
    echo "============================"
    echo "1) Manage Students"
    echo "2) Manage Subjects"
    echo "3) Manage Grades"
    echo "4) Reports & Statistics"
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
        4)
            echo "Opening Reports..."
            sleep 0.5
            manage_reports ;;
        q) echo "Exiting..."; sleep 0.5; exit 0 ;;
        "") echo "Please enter a choice!" ;;
        *) echo "Invalid choice!" ;;
    esac

    echo ""
    read -p "Press Enter to continue..." _
done
