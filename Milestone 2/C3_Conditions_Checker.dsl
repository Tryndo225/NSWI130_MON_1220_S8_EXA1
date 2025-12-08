workspace "Enrollment - Conditions Checker (C3)" "C2-style layout per your template; responsibility-driven C3 for Conditions Checker." {
    
    !identifiers hierarchical

    model {
        ss = softwareSystem "Enrollment Manager" {
            condReader = container "Condition Reader"
            predicateLib = container "Predicate Library"
            condEvaluator = container "Condition Evaluator"
            condCombiner = container "Condition Combiner (AND/OR/NOT)"
            enforceGateway = container "Enforcement Gateway"
            compiledCache = container "Compiled Conditions Cache"
            attrReader = container "Attribute Reader"
            courseRefReader = container "Course Reference Reader"
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

        ss.enforceGateway -> ss.condReader "Fetch active definitions"
        ss.condReader -> ss.compiledCache "Check hot cache"
        ss.condReader -> ss.condSchemaDb "Load if cache miss"
        ss.condReader -> ss.condEvaluator "Provide condition graph"
        ss.condEvaluator -> ss.predicateLib "Invoke predicates (GPA, credits, role, time windows)"
        ss.condEvaluator -> ss.attrReader "Fetch student attributes"
        ss.condEvaluator -> ss.courseRefReader "Fetch course/ticket references"
        ss.condCombiner -> ss.condEvaluator "Evaluate sub-expressions"
        ss.enforceGateway -> ss.condCombiner "Compose results into final decision"
        ss.attrReader -> ss.studentDb "Read attributes (program, year, conflicts)"
        ss.courseRefReader -> ss.courseDb "Read course/ticket refs"
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