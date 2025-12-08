workspace "Enrollment - Ticket Manager (C3, minimal)" "C2-style layout per your template; minimal C3 for Ticket Manager." {
    
    !identifiers hierarchical

    model {
        ss = softwareSystem "Enrollment Manager" {
            ticketCapacityHandler = container "Ticket Capacity Handler"
            ticketStore = container "Ticket Store Adapter"
            enrollmentWriter = container "Enrollment Writer"
            scheduleWriter = container "Schedule Writer"
            waitlistBridge = container "Waitlist Bridge"
            notifierBridge = container "Notifier Bridge"
            studentDb = container "Student Database Schema" {
                tags "Database"
            }
            courseDb = container "Course Database Schema" {
                tags "Database"
            }
        }

        ss.ticketCapacityHandler -> ss.ticketStore "Read capacity/enrolled; write increments"
        ss.ticketCapacityHandler -> ss.enrollmentWriter "On success: update enrolled roster"
        ss.ticketCapacityHandler -> ss.scheduleWriter "On success: update schedule"
        ss.ticketCapacityHandler -> ss.waitlistBridge "On full: push to waiting list"
        ss.ticketCapacityHandler -> ss.notifierBridge "Emit enrollment outcome"
        ss.ticketStore -> ss.courseDb "R/W ticket records"
        ss.enrollmentWriter -> ss.studentDb "Update student course list"
        ss.scheduleWriter -> ss.studentDb "Update schedule entries"
    }

    views {
        systemContext ss "Diagram1" {
            include *
            autolayout lr
        }

        container ss "Diagram2" {
            include *
            autolayout lr
        }

        styles {
            element "Element" {
                color #f88728
                stroke #f88728
                strokeWidth 7
                shape roundedbox
            }
            element "Database" {
                shape cylinder
            }
            element "Boundary" {
                strokeWidth 5
            }
            relationship "Relationship" {
                thickness 4
            }
        }
    }

    configuration {
        scope softwaresystem
    }

}