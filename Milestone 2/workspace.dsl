workspace "EnrollmentSystem workspace" "This workspace documents the architecture of the Enrollment system, a part of a student information system that handles student enrollments." {

    !docs Docs

    model {

        # software systems
        enrollmentSystem = softwareSystem "Enrollment System" "Handles student enrollments and unenrollments, setting and checking enrollment conditions and managing waiting lists."  {

            notificationService = container "Notification Service" "Notifies users about changes in their schedule." {
                templateEngine = component "Template Engine"
                channelDispatcher = component "Channel Dispatcher"
                mailingListManager = component "Mailing List Manager"
                notificationDatabase = component "Notification Database" "Notification view on student database."{
                    tags "Database"
                }

            }

            # ----- Changes -----
            messageBus = container "Message Bus / Event Broker" "Asynchronous messaging backbone used to decouple Enrollment Manager and Notification Service."
            monitoring = container "Monitoring & Metrics" "Collects metrics and logs from other system components for observability and target verification."
            # ----- End -----

            enrollmentManager = container "Enrollment Manager" "Container for ticket management. Manages enrollment, unenrollment and waiting lists." {

                enrollmentAPI = component "Enrollment API" "Handles requests for enrollment/unenrollment"
                ticketCapacityHandler = component "Ticket Capacity Handler"
                ticketStore = component "Ticket Store Adapter"¨
                enrollmentWriter = component "Enrollment Writer"
                scheduleWriter = component "Schedule Writer"

                waitQueue = component "Wait Queue Service"
                autoEnroll = component "Auto-Enroll Worker"

                condReader = component "Condition Reader"
                predicateLib = component "Predicate Library"
                condEvaluator = component "Condition Evaluator"
                condSchemaDatabase = component "Condition Schema Database" {

                    tags "Database"
                }

                # ----- Changes -----
                ticketCache = component "Ticket Cache" "Caches frequently accessed ticket metadata and capacity for read-heavy enrollments."
                eligibilityCache = component "Eligibility Cache" "Caches evaluated eligibility (student + course + conditions version) to reduce repeated condition checks."
                notificationOutbox = component "Notification Outbox" "Persists notifications/events that must be published via the Message Bus, so they are not lost on failures."
                # ----- End -----
            }

            conditionsManager = container "Conditions Manager" "Allows setting and removing enrollment conditions." {
                conditionAPI = component "Condition Management API"
                conditionSchemaDatabase = component "Condition Schema" {
                    tags "Database"
                }

            }
            statisticsEngine = container "Statistics Engine" "Calculates course statistics." {

                statisticsAPI = component "Statistics API"
                statisticsCalculator = component "Statistics calculator" "Calculates statistics"
                statisticsLibrary = component "Statistics library" "Provides basic methods for statistical data analysis."
                statisticsDataFetcher = component "Statistics data fetcher"
                statisticsCache = component "Statistics cache" "Cahces statistics results"

            }


            sisMessenger = container "SIS Messenger" "Allows viewing messages in SIS." {
                tags "Front end"
                messageView = component "Message view" {
                    tags "Front end"
                }
                messageController = component "Message controller"

            }

            enrollmentPresenter = container "Enrollment Presenter" "Presents enrollment/unenrollment options" {
                tags "Front end"
                courseTicketView = component "Course ticket view" {
                    tags "Front end"
                }
                waitingListView = component "Waiting list view" {
                    tags "Front end"
                }

                courseTicketController = component "Course ticket controller"
                waitingListController = component "Waiting list controller"
            }

            coursePresenter = container "Course Presenter" "Presents course info." {
                tags "Front end"
                courseSearchView = component "Course search" {
                    tags "Front end"
                }
                courseSearchController = component "Course search controller"
                courseOverviewView = component "Course overview" {
                    tags "Front end"
                }
                courseOverviewController = component "Course overview controller"
            }

            statisticsPresenter = container "Statistics Presenter" "Presents course statistics" {
                tags "Front end"
                statisticsQueryView = component "Course statistics query view"{
                    tags "Front end"
                }
                statisticsQueryController = component "Course statistics query controller"
            }

            conditionsPresenter = container "Conditions Presenter" "Presents conditions options" {
                tags "Front end"
                conditionSetterView = component "Condition setter view"{
                    tags "Front end"
                }
                conditionListView = component "Condition list view"{
                    tags "Front end"
                }
                conditionSetterContoller = component "Condition setter contoller"
                conditionListController = component "Condition list controller"

            }
            studentPresenter = container "Student Information Presenter" "Presents information about student" {
                tags "Front end"

                studentInfoView = component "Student info view" {
                    tags "Front end"
                }
                studentInfoController = component "Student info component"

                studentSearchView = component "Student search view"{
                    tags "Front end"
                }
                studentSearchController = component "Student search component"

            }

        }

        scheduleModule = softwareSystem "Schedule Module" "Handles course management, scheduling, schedule preferences, viewing schedules and schedule reports." "Existing System"

        studentDatabase = softwareSystem "Student Database" "Stores information about students" "Existing System, Database"

        courseDatabase = softwareSystem "Course Database" "Stores information about courses" "Existing System, Database"

        dashboard = softwareSystem "SIS Dashboard" "Provides a user interface to students, teachers, and study department officers to interact with the Student Information System." "Existing System"

        sso = softwareSystem "Single Sign-On" "Allows users to log in with a single identity to access multiple related software systems." "Existing System"


        # actors
        student = person "Student" "Manages their own course enrollments."
        teacher = person "Teacher" "Manages enrollment conditions for their courses and occasionally student enrollments."
        studyDepartmentOfficer = person "Study Department Officer" "Manages student enrollments in exceptional situations."
        manager = person "Manager" "Views course statistics."

        # relationships between users and EnrollmentSystem
        student -> enrollmentSystem "Enrolls in and unenrolls from courses, views their enrollments and signs up to waiting lists."
        teacher -> enrollmentSystem "Sets enrollment conditions for their course and enrolls and unenrolls students."
        studyDepartmentOfficer -> enrollmentSystem "Enrolls and unenrolls students in exceptional situations."

        # relationships between external systems and enrollmentSystem
        enrollmentSystem -> scheduleModule "Makes API calls to read current schedule for a course from"

        enrollmentSystem -> studentDatabase "Reads information about students from"

        enrollmentSystem -> courseDatabase "Reads information about courses from"

        sso -> enrollmentSystem  "Verifies users' identities."

        dashboard -> enrollmentSystem "Delivers presenters to the user's web browser."

        # Container relationships

        # Context relationships

        student -> sisMessenger "Views messages"
        teacher -> sisMessenger "Views messages"

        student -> enrollmentPresenter "Enrolls (unenrolls) to (from) the course."
        teacher -> enrollmentPresenter "Enrolls (unenrolls) student to (from) the course."
        studyDepartmentOfficer -> enrollmentPresenter "Enrolls (unenrolls) student to (from) the course."

        teacher -> conditionsPresenter "Sets/views conditions."
        studyDepartmentOfficer -> conditionsPresenter "Views conditions."

        student -> coursePresenter "Views available courses and their info."

        manager -> statisticsPresenter "Views statistics."

        enrollmentManager -> courseDatabase "Updates waiting list."
        enrollmentManager -> courseDatabase "Updates enrolled student list."
        enrollmentManager -> courseDatabase "Views conditions."

        enrollmentManager -> studentDatabase "Updates schedule."
        enrollmentManager -> studentDatabase "Views student data."

        coursePresenter -> courseDatabase "Requests course data."

        sso -> sisMessenger "Verifies user"
        sso -> enrollmentPresenter "Verifies user"
        sso -> conditionsPresenter "Verifies user"
        sso -> statisticsPresenter "Verifies user"
        sso -> studentPresenter "Verifies user"

        dashboard -> coursePresenter "Delivers to the user's web browser."
        dashboard -> studentPresenter "Delivers to the user's web browser."
        dashboard -> conditionsPresenter "Delivers to the user's web browser."
        dashboard -> enrollmentPresenter "Delivers to the user's web browser."
        dashboard -> sisMessenger "Delivers to the users's web browser."

        # System relationships

        notificationService -> sisMessenger "Updates messages"

        # ----- Changes -----
        enrollmentManager -> messageBus "Publishes enrollment and waiting-list events"
        messageBus -> notificationService "Delivers events for notification"
        # Monitoring relationships
        enrollmentManager -> monitoring "Sends performance and error metrics"
        notificationService -> monitoring "Sends delivery metrics"
        conditionsManager -> monitoring "Sends condition management metrics"
        statisticsEngine -> monitoring "Sends statistics computation metrics"
        # ----- End -----

        statisticsQueryController -> statisticsAPI "Requests statistics."

        conditionsPresenter -> conditionAPI "Requests conditions and changes them."

        waitingListController -> enrollmentManager "Requests waiting list update"
        courseTicketController -> enrollmentManager "Requests (un)enrollment"

        conditionListController -> conditionAPI "Request conditions info"
        conditionSetterContoller -> conditionAPI "Requests conditions change"

        # ----- Changes -----
        # Previously: autoEnroll -> notificationService "Triggeres notificiation when waiting status changes."
        autoEnroll -> notificationOutbox "Queues notification events when waiting status changes."
        notificationOutbox -> messageBus "Publishes queued notification events"
        # ----- End -----
        notificationService -> messageController "Pushes messages"

        # Enrollemnt Manager components
        ticketStore -> courseDatabase "R/W ticket records"
        condSchemaDatabase -> courseDatabase "Fetch course conditions"
        waitQueue -> courseDatabase "Persist queue state"

        scheduleWriter -> studentDatabase "Update schedule entries"
        enrollmentWriter -> studentDatabase "Update student course list"
        condEvaluator -> studentDatabase "Fetch student attributes"

        enrollmentPresenter -> enrollmentAPI "Requests changes in enrollment."

        ticketCapacityHandler -> ticketStore "Read capacity/enrolled; write increments"
        ticketCapacityHandler -> enrollmentWriter "On success: update enrolled roster"
        ticketCapacityHandler -> scheduleWriter "On success: update schedule"
        ticketCapacityHandler -> autoEnroll "On full: push to waiting list"

        autoEnroll -> waitQueue "Update waiting list"
        autoEnroll -> ticketStore "Update tickets when pop."

        enrollmentAPI -> ticketCapacityHandler "Request (un)enrollment."
        enrollmentAPI -> autoEnroll "Request removal from waiting list."
        ticketCapacityHandler -> autoEnroll "Request waiting list update when user unenrolls."

        ticketCapacityHandler -> condEvaluator "Check conditions"
        condReader -> condSchemaDatabase "Fetch conditions."
        condEvaluator -> condReader "Fetch condition graph"
        condEvaluator -> predicateLib "Invoke predicates (GPA, credits, role, time windows)"

        # ----- Changes -----
        # New cache-related relationships
        enrollmentAPI -> ticketCache "Reads frequently accessed ticket metadata"
        ticketCapacityHandler -> ticketCache "Reads and updates cached ticket capacity"

        enrollmentAPI -> eligibilityCache "Checks cached eligibility"
        condEvaluator -> eligibilityCache "Stores eligibility results for reuse"

        enrollmentAPI -> notificationOutbox "Queues enrollment notifications"
        # notificationOutbox already publishes to messageBus above
        # ----- End -----

        # Statistics Engine components
        statisticsDataFetcher -> courseDatabase "Fetches data"

        statisticsAPI -> statisticsCalculator "Requests calculation"
        statisticsCalculator -> statisticsDataFetcher "Requests data fetch"
        statisticsLibrary -> statisticsCalculator "Provides statistical methods."
        statisticsCalculator -> statisticsCache "Updates"
        statisticsCalculator -> statisticsCache "Reads"

        # Enrollment Presenter components
        dashboard -> courseTicketView "delivers"
        dashboard -> waitingListView "delivers"

        waitingListView -> waitingListController "Handles waiting list requests"
        courseTicketView -> courseTicketController "Handles (un)enrollment requests."

        # Course Presenter components
        dashboard -> courseSearchView "delivers"
        dashboard -> courseOverviewView "delivers

        courseSearchController -> courseDatabase "Fetches available courses based on user filters."
        courseOverviewController -> courseDatabase "Fetches course data"

        courseSearchView -> courseSearchController "Requests course list"
        courseOverviewView -> courseOverviewController "Requests course data"

        # Statistics Presenter components
        statisticsQueryView -> statisticsQueryController "Sets statistics to be calculated"

        # Conditions Presenter components
        dashboard -> conditionListView "Delivers"
        dashboard -> conditionSetterView "Delivers"

        conditionListView -> conditionListController "Request conditions"
        conditionSetterView -> conditionSetterContoller "Requests condition change"

        # Student Presenter components
        studentInfoController -> studentDatabase "Fetches data from databse"
        studentSearchController -> studentDatabase "Fetches data about students"
        dashboard -> studentInfoView "Delivers"
        dashboard -> studentSearchView "Delivers"

        studentInfoView -> studentInfoController "Gets data about student"
        studentSearchView -> studentSearchController "Gets data about students"

        # SIS Messenger
        dashboard -> messageView "Delivers"

        messageView -> messageController "Gets messages"

        # Notification Service
        channelDispatcher -> studentDatabase "Lookup contact addresses"
        notificationDatabase -> studentDatabase "Stores and loads notifications and logs."

        channelDispatcher -> templateEngine "Render message"
        channelDispatcher -> mailingListManager "Publish to mailing lists"
        channelDispatcher -> notificationDatabase "Write delivery logs"

        # Conditions manager
        conditionSchemaDatabase -> courseDatabase "Sets/removes conditions."

        conditionAPI -> conditionSchemaDatabase "Create/Update/Delete condition definitions"


        # Deployment environments

        deploymentEnvironment "Production" {
            deploymentNode "User's web browser" "" "" {
                containerInstance enrollmentPresenter
                containerInstance coursePresenter
                containerInstance statisticsPresenter
                containerInstance conditionsPresenter
                containerInstance studentPresenter
                containerInstance sisMessenger
            }

            deploymentNode "Notification server" "" "" {
                containerInstance notificationService
            }

            deploymentNode "Enrollment server" "" "" {
                containerInstance enrollmentManager
            }

            deploymentNode "Conditions server" "" "" {
                containerInstance conditionsManager
            }

            deploymentNode "Statistics server" "" "" {
                containerInstance statisticsEngine
            }

            # ----- Changes -----
            deploymentNode "Messaging server" "" "" {
                containerInstance messageBus
            }

            deploymentNode "Monitoring server" "" "" {
                containerInstance monitoring
            }
            # ----- End -----
        }

        deploymentEnvironment "Development" {
            deploymentNode "User's web browser" "" "" {
                containerInstance enrollmentPresenter
                containerInstance coursePresenter
                containerInstance statisticsPresenter
                containerInstance conditionsPresenter
                containerInstance studentPresenter
                containerInstance sisMessenger
            }

            deploymentNode "Back end server" "" "" {
                containerInstance notificationService
                containerInstance enrollmentManager
                containerInstance conditionsManager
                containerInstance statisticsEngine

                # ----- Changes -----
                containerInstance messageBus
                containerInstance monitoring
                # ----- End -----
            }
        }

        #!docs Docs
    }

    views {

        systemContext enrollmentSystem "enrollmentSystemContextDiagram" {
            include enrollmentSystem
            include scheduleModule
            include studentDatabase
            include courseDatabase
            include dashboard
            include sso
            include student
            include teacher
            include studyDepartmentOfficer
            include manager
        }
        container enrollmentSystem "enrollmentSystemContainerDiagram" {
            include *
            exclude courseTicketView
            exclude waitingListView
            exclude courseSearchView
            exclude courseOverviewView
            exclude conditionListView
            exclude conditionSetterView
            exclude studentInfoView
            exclude studentSearchView
            exclude messageView

        }

        dynamic enrollmentSystem {
            title "Core feature 1: Student enrolls himself in a course"
            description "The student meets all course conditions, the course capacity has not yet been filled and authentication was procceed successfully."
            sso -> enrollmentPresenter "Veriffies the student"
            student -> enrollmentPresenter "Requests a course enrollment"
            enrollmentPresenter -> enrollmentManager "Requests the student enrollment in the course"
            enrollmentManager -> courseDatabase "Fetches the course enrollment conditions"
            enrollmentManager -> courseDatabase "Updates enrolled student list"
            enrollmentManager -> studentDatabase "Adds the course in the student's course list"
            # ----- Changes -----
            # Previously: enrollmentManager -> notificationService ...
            enrollmentManager -> messageBus "Publishes enrollment success event"
            messageBus -> notificationService "Delivers enrollment event for notification"
            # ----- End -----
            notificationService -> sisMessenger "Requests to show enrollment success message to the student"
            autoLayout lr
        }

        dynamic enrollmentSystem {
            title "Core feature 2: Student cancels own enrollment in a course"
            description "The student requests course enrollment cancellation for a course, which enrollment cancellation conditions has been met."
            student -> enrollmentPresenter "Requests enrollment course cancellation"
            enrollmentPresenter -> enrollmentManager "Requests the student enrollment course cancellation"
            # ----- Changes -----
            # Previously: enrollmentManager -> notificationService "Requests confirmation message about course enrollment cancellation"
            enrollmentManager -> messageBus "Publishes enrollment cancellation request event"
            messageBus -> notificationService "Delivers cancellation request event"
            # ----- End -----
            notificationService -> sisMessenger "Requests to show confirmation message about course enrollment cancellation message to the student"
            student -> enrollmentPresenter "Confirms enrollment course cancellation"
            enrollmentPresenter -> enrollmentManager "Confirms the student enrollment course cancellation"
            enrollmentManager -> courseDatabase "Fetches the course enrollment cancellation conditions"
            enrollmentManager -> courseDatabase "Updates enrolled student list"
            enrollmentManager -> studentDatabase "Remove the course from the student's course list"
            # ----- Changes -----
            # Previously: enrollmentManager -> notificationService "Triggers notification about the student successful course enrollment cancellation"
            enrollmentManager -> messageBus "Publishes enrollment cancellation success event"
            messageBus -> notificationService "Delivers enrollment cancellation success event"
            # ----- End -----
            notificationService -> sisMessenger "Requests to show course enrollment cancellation success message to the student"
            autoLayout lr
        }

        dynamic enrollmentSystem {
            title "Core feature 5: Study department officer enrolls a student"
            studyDepartmentOfficer -> enrollmentPresenter "Requests enrollment of a student in a course"
            enrollmentPresenter -> enrollmentManager "Requests a student enrollment for a course"
            enrollmentManager -> studentDatabase "Requests a list of students"
            studyDepartmentOfficer -> enrollmentPresenter "Requests enrollment of a concrete student in a course"
            enrollmentPresenter -> enrollmentManager "Requests enrollment of the student in a course"
            enrollmentManager -> studentDatabase "Requests the student data"
            enrollmentManager -> courseDatabase "Fetches data about enrollable courses"
            studyDepartmentOfficer -> enrollmentPresenter "Requests enrollment of the student in a concrete course"
            enrollmentPresenter -> enrollmentManager "Requests enrollment of the student in the course"
            # ----- Changes -----
            # Previously: enrollmentManager -> notificationService "Requests confirmation message about course enrollment"
            enrollmentManager -> messageBus "Publishes enrollment confirmation request event"
            messageBus -> notificationService "Delivers enrollment confirmation request event"
            # ----- End -----
            notificationService -> sisMessenger "Requests to show confirmation message about course enrollment to the study department officer"
            studyDepartmentOfficer -> enrollmentPresenter "Confirms course enrollment"
            enrollmentPresenter -> enrollmentManager "Requests (confirmed) enrollment of the student in the course"
            enrollmentManager -> courseDatabase "Update course enrollment list"
            enrollmentManager -> studentDatabase "Update enrolled courses for the student"
            # ----- Changes -----
            # Previously: enrollmentManager -> notificationService "Requests message about the course enrollment for the student"
            enrollmentManager -> messageBus "Publishes enrollment completed event"
            messageBus -> notificationService "Delivers enrollment completed event"
            # ----- End -----
            autoLayout lr
        }

        dynamic enrollmentSystem {
            title "Core feature 7: Teacher adds an enrollment condition to his course"
            description "Case when the condition which teacher tries to add is valid."
            sso -> enrollmentPresenter "Veriffies the teacher"
            teacher -> enrollmentPresenter "Requests management of his course"
            enrollmentPresenter -> enrollmentManager "Requests course management for the teacher"
            enrollmentManager -> courseDatabase "Fetches courses taught by the teacher"
            teacher -> enrollmentPresenter "Requests management of the course"
            enrollmentPresenter -> enrollmentManager "Requests the course management for the teacher"
            enrollmentManager -> courseDatabase "Fetches the course data"
            teacher -> enrollmentPresenter "Requests edition of the course enrollment condition"
            enrollmentPresenter -> enrollmentManager "Requests edition of the course enrollment condition for the teacher"
            enrollmentManager -> courseDatabase "Fetches the current course enrollment conditions"
            enrollmentManager -> courseDatabase "Fetches the available course enrollment condition types"
            teacher -> enrollmentPresenter "Requests to add new course enrollment condition"
            enrollmentPresenter -> enrollmentManager "Requests to add new course enrollment condition for the teacher"
            enrollmentManager -> studentDatabase "Fetches data about directly affective students by this change"
            teacher -> enrollmentPresenter "Requests to save the new course enrollment condition"
            enrollmentPresenter -> enrollmentManager "Requests to save the new course enrollment condition for the course"
            enrollmentManager -> courseDatabase "Add the new course enrollment condition for the course"
            # ----- Changes -----
            # Previously: enrollmentManager -> notificationService "Request course enrollment condition added successfully message for the teacher"
            enrollmentManager -> messageBus "Publishes condition changed event"
            messageBus -> notificationService "Delivers condition changed event"
            # ----- End -----
            notificationService -> sisMessenger "Request course enrollment condition added successfully message for the teacher"
            # unenroll students, which fail to pass the new course enrollmenta condition
            enrollmentManager -> courseDatabase "Remove student(s) from the course enrollment list"
            enrollmentManager -> studentDatabase "Remove the course from enrolled student list"
            # ----- Changes -----
            # Previously: enrollmentManager -> notificationService "Request course enrollment cancellation due to change in course enrollment condition for student(s)"
            enrollmentManager -> messageBus "Publishes enrollment cancellation due to condition change event"
            messageBus -> notificationService "Delivers enrollment cancellation due to condition change event"
            # ----- End -----
            notificationService -> sisMessenger "Request course enrollment cancellation due to change in course enrollment condition for student(s)"
            enrollmentManager -> courseDatabase "Fetches course enrollment condition for the course"
            autoLayout lr
        }

        component enrollmentManager "enrollmentManagerComponeentDiagram" {
            include *
        }
        component statisticsEngine "statisticsEnginComponentDiagram" {
            include *
        }
        component enrollmentPresenter "enrollmentPresenterComponentDigram" {
            include *
        }
        component coursePresenter "coursePresenterComponentDiagram" {
            include *
        }

        component statisticsPresenter "statisticsPresenterComponentDiagram" {
            include *
        }
        component conditionsPresenter "conditionsPresenterComponentDiagram" {
            include *
        }
        component studentPresenter "studentPresenterComponentDiagram" {
            include *
        }
        component sisMessenger "sisMessengerComponentDiagram" {
            include *
        }
        component notificationService "notificationServiceComponentDiagram" {
            include *
        }
        component conditionsManager "conditionsManagerComponentDiagram" {
            include *
        }

        deployment enrollmentSystem "Production" "Production_Deployment"   {
            include *
        }

        deployment enrollmentSystem "Development" "Development_Deployment"   {
            include *
        }

        theme default

        styles {
            element "Existing System" {
                background #999999
                color #ffffff
            }
            element "Database" {
                shape cylinder
            }
            element "Front end" {
                shape webBrowser
            }
        }
    }
}
