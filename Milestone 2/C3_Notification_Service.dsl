workspace "Enrollment - Notification Service (C3, minimal)" "C2-style layout per your template; minimal C3 for Notification Service." {
    
    !identifiers hierarchical

    model {
        ss = softwareSystem "Enrollment Manager" {
            templateEngine = container "Template Engine"
            channelDispatcher = container "Channel Dispatcher"
            mailingListMgr = container "Mailing List Manager"
            notifLogDb = container "Notification Log" {
                tags "Database"
            }
            studentDb = container "Student Database" {
                tags "Database"
            }
        }

        ss.channelDispatcher -> ss.templateEngine "Render message"
        ss.channelDispatcher -> ss.mailingListMgr "Publish to mailing lists"
        ss.channelDispatcher -> ss.notifLogDb "Write delivery logs"
        ss.channelDispatcher -> ss.studentDb "Lookup contact addresses"
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