workspace "Enrollment - Conditions Manager (C3, minimal)" "C2-style layout per your template; minimal C3 for Conditions Manager." {
    
    !identifiers hierarchical

    model {
        ss = softwareSystem "Enrollment Manager" {
            # Straightforward internal containers
            conditionAPI = container "Condition Management API"

            # Reused existing containers
            conditionsChecker = container "Conditions Checker"
            notificationService = container "Notification Service"
            authenticator = container "Authenticator"

            # Databases
            condSchemaDb = container "Condition Schema" {
                tags "Database"
            }
            studentDb = container "Student Database Schema" {
                tags "Database"
            }
            courseDb = container "Course Database Schema" {
                tags "Database"
            }
        }

        # Minimal, clear relationships
        ss.conditionAPI -> ss.authenticator "Authorize teachers/officers"
        ss.conditionAPI -> ss.condSchemaDb "Create/Update/Delete condition definitions"
        ss.conditionAPI -> ss.notificationService "Notify stakeholders on changes"
        ss.conditionAPI -> ss.conditionsChecker "Validate or dry-run a condition"
        ss.conditionsChecker -> ss.studentDb "Read student attributes"
        ss.conditionsChecker -> ss.courseDb "Read course references"
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