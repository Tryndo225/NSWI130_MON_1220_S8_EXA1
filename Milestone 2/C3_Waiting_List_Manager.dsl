workspace "Enrollment - Waiting List Manager (C3)" "C2-style layout per your template; responsibility-driven C3 for Waiting List Manager." {
    
    !identifiers hierarchical

    model {
        ss = softwareSystem "Enrollment Manager" {
            waitQueue = container "Wait Queue Service"
            positionCalc = container "Position Calculator"
            eligibility = container "Eligibility Checker"
            autoEnroll = container "Auto-Enroll Worker"
            identityResolver = container "Identity Resolver"
            queueRepo = container "Queue Repository Adapter"
            eventEmitter = container "Waitlist Event Emitter"
            studentDb = container "Student Database" {
                tags "Database"
            }
            courseDb = container "Course Database" {
                tags "Database"
            }
        }

        ss.waitQueue -> ss.positionCalc "Calculate user position"
        ss.waitQueue -> ss.queueRepo "Persist enqueue/dequeue"
        ss.autoEnroll -> ss.queueRepo "Peek/pop head"
        ss.autoEnroll -> ss.eligibility "Check course/student constraints"
        ss.autoEnroll -> ss.eventEmitter "Emit status change events"
        ss.autoEnroll -> ss.waitQueue "Mark processed"
        ss.eligibility -> ss.courseDb "Read ticket capacity/current"
        ss.eligibility -> ss.studentDb "Read student profile & conflicts"
        ss.identityResolver -> ss.studentDb "Resolve student identifiers"
        ss.queueRepo -> ss.courseDb "Persist queue state"
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