workspace "Exam Handling System" "C4 – feature containers with per-container modules" {

    model {
        // People
        student = person "Student" "Registers for exams and gets notifications."
        teacher = person "Teacher" "Creates/edits exam terms and moderates credits/grades."
        // Externals
        schoolMail = softwareSystem "School Email" "Delivers e-mails."
        schoolDatabase   = softwareSystem "School DataBase" "Students, courses, enrollment, results."
    
            // Subsystem 1 – Exam Registration
            examReg = softwareSystem "Exam Registration" "Student exam sign-up + teacher exam-term management." "Web/API" {

                    erInputfieldHandler = container "P: Inputfield Handler" "Handles inputfield rendering and manipulation" "Web" {

                        logInPage = component "Serve Log-In Page" "Serves the log-in page and handles inputs"
                        lookUpWindows = component "Display Look Up Window" "Displays and captures input of look up windows (course/premise/student/teacher etc.)"
                        examCreationIH = component "Display Exam Creation Window" "Displays and captures input of exam creation windows with related fields"
                    }

                    erListHandler = container "P: Shows Lists of Items" "Handles list rendering and manipulation" "Web" {
                        examList = component "Render List of Exam Terms" "Handles showing list of exam terms and manipulation of set list"
                        coursesTaughtList = component "Render List of Courses" "Handles showing list of courses and manipulation of set list"
                        premisesList = component "Render List of Premises" "Handles showing list of premises and manipulation of set list"
                        studentList = component "Render List of Students" "Handles showing list of students and manipulation of set list"
                    }

                    erAlertsDisplay = container "P: Display Pop-Up Windows" "Handles displaying pop-up windows" {
                        examCreationPU = component "Display Exam Creation Pop-Up" "Displays successful/failed exam creation pop-up notification with relevant information"
                        examDataChangePU = component "Display Exam Info Change Pop-Up" "Displays successful/failed exam data changed pop-up notification with relevant information"
                        examLoginPU = component "Display Exam Term Join Pop-Up" "Displays successful/failed exam term joining pop-up notification with relevant information"
                        examLeavePU = component "Display Exam Term Leave Pop-Up" "Displays successful/failed exam term leaving pop-up notification with relevant information"
                        examChangePU = component "Display Exam Term Change Pop-Up" "Displays successful/failed exam term changed pop-up notification with relevant information"
                        examWaitingPu = component "Display Exam Term Waiting Room Pop-Up" "Displays successful/failed exam term waiting room pop-up notification with relevant information"
                    }

                    erAlertsGenerator = container "A: Generate Notifications" "Generates notification and handles target selection (email/pop-up)" {
                        generateExamCreationNot = component "Generate Exam Creation Pop-Up" "Generates exam creation pop-up notification with relevant information"
                        generateExamDataChangeNot = component "Generate Exam Info Change Pop-Up" "Generates exam data changed pop-up notification with relevant information"
                        generateExamLoginNot = component "Generate Exam Term Join Pop-Up" "Generates exam term joined pop-up notification with relevant information"
                        generateOfflineExamChange = component "Generate Exam Term Change Email" "Generates exam term email notification with relevant information (when user offline)"
                        generateExamLeaveNot = component "Display Exam Term Leave Pop-Up" "Generates exam term leaving pop-up notification with relevant information"
                        generateExamChangeNot = component "Display Exam Term Change Pop-Up" "Generates exam term changed pop-up notification with relevant information" 
                    }

                    erDisplayInformationWindow = container "P/A: Displays Information About Element" "Displays detailed information about UI elements" {
                        renderExamTerm = component "Render Exam Term" "Displays exam term with its detailed information"
                        renderCourse = component "Render Course" "Displays course with its detailed information"
                    }

                    erAuthenticator = container "A/I: Log-In Authentication" "Checks user information against user data in database"

                    erInputSanitization = container "A: Sanitize User Input" "Sanitizes user inputted data" {
                        sanitizeCourse = component "Sanitize Course" "Sanitizes input data from course look-up"
                        sanitizePremise = component "Sanitize Premise" "Sanitizes input data from premise look-up"
                        sanitizeExamCreation = component "Sanitize Exam Creation" "Sanitizes input data from course creation fields"
                        sanitizeLogIn = component "Sanitize Log-In" "Sanitizes input data from log-in fields"
                    }

                    erFilterListsData = container "A: Filter Lists" "Filters lists for relevant information" {
                        filterCoursesTaught = component "Filter Courses by Teacher" "Filters courses for courses taught by teacher"
                        filterCoursesName = component "Filter Courses by Name" "Filters courses by matching name"
                        filterExamTerms = component "Filter Exam Terms" "Filters exam terms by matching name/time/date/teacher/subject"
                        filterPremises = component "Filter Premises" "Filters premises by name/location/availability"
                        filterStudents = component "Filter Students" "Filters students by exam term attending"
                    }

                    erDatabaseFetcher = container "I: Handle Database Fetch" "Handles fetching information from database" {
                        fetchCourse = component "Fetch Courses" "Fetches all courses from the database"
                        fetchTeacher = component "Fetch Teachers" "Fetches all teachers from the database"
                        fetchExams = component "Fetch Exam Terms" "Fetches all current exam term from the database"
                        fetchLogIn = component "Fetch Log-In Data" "Fetches log-in data for given user from the database"
                        fetchPremises = component "Fetch Premises" "Fetches all premises from the database"
                        fetchStudents = component "Fetch Students" "Fetches all students from the database"
                    }

                    erDatabaseUpdate = container "I: Handle Database Update" "Handles updating database with new information" {
                        createExamTerm = component "Handle New Exam Term" "Handles uploading new exam term to the database"
                        updateAttendingJoin = component "Handle Student Term Join" "Handles updating students attending an exam term"
                        updateAttendingLeave = component "Handle Student Term Leave" "Handles updating students attending an exam term"
                        updateExamTerm = component "Handle Exam Term Update" "Handles updating exam term with new information"
                    }

                    erActionLogger = container "I: Log User Action and Notification" "Logs all user action and following system responses" {
                        logLogIn = component "Log User Log-Ins" "Logs in all user log-in for security reasons"
                        logChanges = component "Log User Changes" "Logs all changes user has done in the system"
                        logResponse = component "Log System Feedbacks" "Logs system responses to user for easy debugging"
                    }

                    erEmailHandler = container "A: Handle Email System" "Passes emails to be sent by the emailing system"

                    student -> erInputfieldHandler "inputs data"
                    teacher -> erInputfieldHandler "inputs data"

                    student -> erListHandler "interacts with"
                    teacher -> erListHandler "interacts with"

                    student -> erDisplayInformationWindow "views"
                    teacher -> erDisplayInformationWindow "views"

                    erAlertsDisplay -> student "notifies"
                    erAlertsDisplay -> teacher "notifies"

                    // Log-In Flow
                    erInputfieldHandler -> erInputSanitization "passes inputted data"
                    erInputSanitization -> erAuthenticator "passes sanitized data"
                    erAuthenticator -> erInputfieldHandler "notifies"
                    erAuthenticator -> erAlertsGenerator "notifies"
                    erAlertsGenerator -> erAlertsDisplay "passes notification"
                    erAuthenticator -> erActionLogger "notifies"

                    // Search Flow
                    erInputSanitization -> erFilterListsData "passes sanitized data"
                    erFilterListsData -> erDatabaseFetcher "requests data"
                    erDatabaseFetcher -> erFilterListsData "passes data"
                    erDatabaseFetcher -> schoolDatabase "requests data"
                    schoolDatabase -> erDatabaseFetcher "passes data"
                    erFilterListsData -> erListHandler "passes filtered list"

                    // Exam Update Flow
                    erInputSanitization -> erDatabaseUpdate "passes update data"
                    erDatabaseUpdate -> erAlertsGenerator "notifies"
                    erDatabaseUpdate -> schoolDatabase "updates data"
                    erDatabaseUpdate -> erActionLogger "notifies"

                    // Individual Element
                    erListHandler -> erDisplayInformationWindow "passes element"
                    erDisplayInformationWindow -> erDatabaseFetcher "requests data"
                    erDatabaseFetcher -> erDisplayInformationWindow "sends data"

                    // Email
                    erAlertsGenerator -> erEmailHandler "passes email"
                    erAlertsGenerator -> erActionLogger "notifies"
                }

                // CONTAINER 2 – Course Credit Moderation
                creditMod = container "Course Credit Moderation" "Teacher sets/changes credit (zápočet)." "Web/API" {
                    cmUI   = component "CM: Credit Moderation UI" "Form/table to set credit for students." "Web"
                    cmApp  = component "CM: Application Service" "Validates teacher, applies credit change." "Service"
                    cmRepo = component "CM: Student Result Access" "Reads/writes credit info in IS." "DB/Integration"

                    teacher -> cmUI "uses"
                    cmUI -> cmApp "set credit"
                    cmApp -> cmRepo "write credit change"
                }

                // CONTAINER 3 – Course Grade Moderation
                gradeMod = container "Course Grade Moderation" "Teacher sets/changes grade for students." "Web/API" {
                    gmUI   = component "GM: Grade Moderation UI" "Form/table to set grade." "Web"
                    gmApp  = component "GM: Application Service" "Validates teacher, applies grade change." "Service"
                    gmRepo = component "GM: Student Result Access" "Reads/writes grade info in IS." "DB/Integration"

                    teacher -> gmUI "uses"
                    gmUI -> gmApp "set grade"
                    gmApp -> gmRepo "write grade change"
                }

                // container-level external calls
                examReg   -> schoolDatabase "fetch/update data"
                creditMod -> schoolDatabase "get student/course"
                gradeMod  -> schoolDatabase "get student/course"
            }

            // deployments
            deploymentEnvironment "Development" {
                deploymentNode "Dev machine" {
                    containerInstance examReg
                    containerInstance creditMod
                    containerInstance gradeMod
                }
                deploymentNode "School services (mock)" {
                    softwareSystemInstance schoolMail
                    softwareSystemInstance schoolDatabase
                }
            }

            deploymentEnvironment "Production" {
                deploymentNode "K8s / App cluster" {
                    containerInstance examReg
                    containerInstance creditMod
                    containerInstance gradeMod
                }
                deploymentNode "School services" {
                    softwareSystemInstance schoolMail
                    softwareSystemInstance schoolDatabase
                }
            }
        }
        
            styles {
                element "Person" {
                    shape person
                    background #08427b
                    color #ffffff
                }
                element "Software System" {
                    background #1168bd
                    color #ffffff
                }
                element "Container" {
                    background #438dd5
                    color #ffffff
                }
                element "Component" {
                    background #dbeafe
                    color #000000
                }
        }
    }
}
