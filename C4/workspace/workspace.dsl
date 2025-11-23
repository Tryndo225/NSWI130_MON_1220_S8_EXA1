workspace "Exam Handling System" "C4 model for EXA project" {

    model {

        // === People ===
        student = person "Student" "Registers for exams and views results."
        teacher = person "Teacher" "Creates exam terms, reserves rooms, assigns credits and grades."
        manager = person "Manager" "Views exam statistics and historical reports."

        // === External systems ===
        sis  = softwareSystem "School Information System" "Master data about students, courses, enrolment and official results."
        mail = softwareSystem "School Email" "Delivers e-mail notifications."

        // === Our system ===
        healthExa = softwareSystem "Exam Handling System (EXA)" "Manages exam terms, registrations, rooms, results and statistics." {

            // ----- Container: Web UI -----
            webApp = container "Web Application" "Web UI for students, teachers and managers." "Web application" {

                loginPage           = component "Login Page & Auth Guard" "Authenticates users and protects exam features."
                registrationPage    = component "Exam Registration Page" "Course lookup, exam term list and term selection."
                examManagementPage  = component "Exam Term Management Page" "Shows teacher's exam terms and opens the editor."
                roomReservationPage = component "Room Reservation Page" "Displays available rooms and 'Other location' selector."
                resultsPage         = component "Results & History Page" "Shows exam outcomes, grades and statistics."
                notificationWidget  = component "Notification Widget" "Displays success/error messages and alerts."
            }

            // ----- Container: Application Core -----
            appCore = container "Application Core" "Business logic for exam registration, room reservation, credits and grades." "Application service" {

                authService             = component "Authentication Service" "Provides the current user identity."
                courseLookupService     = component "Course Lookup Service" "Resolves courses from code/name and handles 'course not found'."
                examTermQueryService    = component "Exam Term Query Service" "Retrieves exam terms for a course or a teacher."
                registrationWorkflow    = component "Registration Workflow Service" "Coordinates the full student exam registration process."
                eligibilityService      = component "Eligibility Check Service" "Checks enrolment, max registration count, existing registrations and credit requirements."
                capacityService         = component "Capacity Check Service" "Verifies and reserves capacity for an exam term."
                roomAvailabilityService = component "Room Availability Service" "Looks up free rooms for a time period."
                roomReservationService  = component "Room Reservation Service" "Assigns a room or external location to an exam term."
                creditService           = component "Credit Assignment Service" "Allows teachers to record per-student course credit."
                gradeService            = component "Grade Assignment Service" "Allows teachers to record per-student course grades."
                statisticsService       = component "Statistics Service" "Builds aggregated reports for managers and teachers."
                examRepository          = component "Exam Repository" "Reads and writes exam terms, rooms, registrations and results in the Exam Database."
                notificationFacade      = component "Notification Facade" "Creates domain events and forwards them to the Notification Worker."
            }

            // ----- Container: Notification Worker -----
            notificationWorker = container "Notification Worker" "Asynchronously builds and sends e-mail notifications and logs delivery." "Background worker" {

                registrationNotifier    = component "Registration Notifier" "Creates messages for successful or failed exam registrations."
                roomReservationNotifier = component "Room Reservation Notifier" "Creates messages for successful room reservations or updates."
                resultNotifier          = component "Result Notifier" "Sends messages when credits or grades are recorded."
                emailSender             = component "Email Sender" "Sends e-mails via the School Email system."
                notificationLog         = component "Notification Log" "Persists notification metadata and delivery status."
            }

            // ----- Container: Database -----
            exaDb = container "Exam Database" "Stores exam terms, registrations, rooms, credits, grades and statistics." "Relational database schema" {
                tags "Database"

                examsSchema         = component "Exam Terms Schema" "Tables for exam terms and assigned rooms."
                registrationsSchema = component "Registrations Schema" "Tables for student registrations."
                resultsSchema       = component "Results Schema" "Tables for per-student credits and grades."
                statsSchema         = component "Statistics Schema" "Derived and historical statistics."
            }
        }

        // === System-level relationships (L1) ===
        student -> healthExa "Uses for exam registration and viewing results" "HTTPS"
        teacher -> healthExa "Uses for exam management, rooms, credits and grades" "HTTPS"
        manager -> healthExa "Uses for statistics and reports" "HTTPS"

        healthExa -> sis  "Reads course and enrolment data; writes official results and credits" "REST/DB"
        healthExa -> mail "Sends notification e-mails" "SMTP"

        // === Container-level relationships (L2) ===
        student -> webApp "Uses via browser" "HTTPS"
        teacher -> webApp "Uses via browser" "HTTPS"
        manager -> webApp "Uses via browser" "HTTPS"

        webApp -> appCore "Invokes application use cases" "HTTPS/JSON"

        appCore -> exaDb "Reads from and writes to exam data" "JDBC"
        appCore -> sis   "Reads enrolment/requirements; writes results" "REST/DB"
        appCore -> notificationWorker "Publishes notification events" "Async message / queue"

        notificationWorker -> mail  "Sends e-mails" "SMTP"
        notificationWorker -> exaDb "Logs notification status" "JDBC"

        // === Component relationships (L3 – key ones only) ===
        loginPage        -> authService          "Authenticates user via"
        registrationPage -> courseLookupService  "Searches course via"
        registrationPage -> examTermQueryService "Loads exam terms via"
        registrationPage -> registrationWorkflow "Submits registration to"

        examManagementPage  -> examTermQueryService    "Loads teacher exam terms via"
        roomReservationPage -> roomAvailabilityService "Requests available rooms via"
        roomReservationPage -> roomReservationService  "Saves chosen room via"

        resultsPage        -> statisticsService "Requests statistics via"
        notificationWidget -> notificationFacade "Subscribes to notification status via"

        registrationWorkflow -> eligibilityService "Delegates eligibility checks to"
        registrationWorkflow -> capacityService    "Delegates capacity check to"
        registrationWorkflow -> examRepository     "Creates/updates registration via"
        registrationWorkflow -> notificationFacade "Publishes registration events to"

        roomReservationService -> roomAvailabilityService "Validates chosen room via"
        roomReservationService -> examRepository          "Updates exam term room via"
        roomReservationService -> notificationFacade      "Publishes room reservation events to"

        creditService -> examRepository     "Updates credit status via"
        creditService -> notificationFacade "Publishes credit events to"

        gradeService  -> examRepository     "Updates grade status via"
        gradeService  -> notificationFacade "Publishes grade events to"

        statisticsService -> exaDb "Reads statistics and results from"

        examRepository -> exaDb "Reads/writes exams, registrations and results"

        notificationFacade -> notificationWorker "Sends notification commands to"

        registrationNotifier    -> emailSender      "Uses"
        roomReservationNotifier -> emailSender      "Uses"
        resultNotifier          -> emailSender      "Uses"
        registrationNotifier    -> notificationLog  "Writes"
        roomReservationNotifier -> notificationLog  "Writes"
        resultNotifier          -> notificationLog  "Writes"

        // === Deployment environments (for 2 deployment diagrams) ===
        deploymentEnvironment "Dev/Test" {
            deploymentNode "Developer Laptop" "Local development or test environment" "Docker / local runtime" {
                containerInstance webApp
                containerInstance appCore
                containerInstance notificationWorker
                deploymentNode "Local DB" "Test database" "PostgreSQL" {
                    containerInstance exaDb
                }
            }
            deploymentNode "External systems (dev stubs)" "" "" {
                softwareSystemInstance sis
                softwareSystemInstance mail
            }
        }

        deploymentEnvironment "Production" {
            deploymentNode "Kubernetes Cluster" "Production app cluster" "Kubernetes" {
                deploymentNode "Web Pod" "" "" {
                    containerInstance webApp
                }
                deploymentNode "App Pod" "" "" {
                    containerInstance appCore
                }
                deploymentNode "Worker Pod" "" "" {
                    containerInstance notificationWorker
                }
            }
            deploymentNode "DB Server" "Managed relational database" "PostgreSQL" {
                containerInstance exaDb
            }
            deploymentNode "External systems" "" "" {
                softwareSystemInstance sis
                softwareSystemInstance mail
            }
        }
    }

    views {

        // ===== L1 – System context =====
        systemContext healthExa "exaSystemContextDiagram" {
            include *
        }

        // ===== L2 – Containers =====
        container healthExa "exaContainerDiagram" {
            include *
        }

        // ===== L3 – Components (one per container) =====
        component webApp "exaWebAppComponentDiagram" {
            include *
        }

        component appCore "exaCoreComponentDiagram" {
            include *
        }

        component notificationWorker "exaNotificationComponentDiagram" {
            include *
        }

        component exaDb "exaDbComponentDiagram" {
            include *
        }

        // ===== Dynamic diagrams – one per feature =====

        dynamic healthExa "studentExamRegistrationDynamic" {
            title "Feature: Student exam registration"
            student  -> webApp             "Opens exam registration UI"
            webApp   -> appCore            "Requests exam terms for selected course"
            appCore  -> sis                "Reads course and requirement data"
            appCore  -> exaDb              "Reads existing exam terms and registrations"
            webApp   -> appCore            "Submits registration for chosen term"
            appCore  -> sis                "Checks enrolment and credit status"
            appCore  -> exaDb              "Checks and reserves capacity, stores registration"
            appCore  -> notificationWorker "Publishes registration-created event"
            notificationWorker -> mail     "Sends confirmation e-mail"
            student  -> webApp             "Sees registration confirmation"
        }

        dynamic healthExa "roomReservationDynamic" {
            title "Feature: Reservation of exam premises"
            teacher -> webApp             "Opens exam term management UI"
            webApp  -> appCore            "Requests teacher's exam terms"
            appCore -> exaDb              "Reads exam terms for teacher"
            teacher -> webApp             "Chooses an exam term and opens room selection"
            webApp  -> appCore            "Requests available rooms for that term"
            appCore -> exaDb              "Checks existing room reservations"
            appCore -> exaDb              "Marks chosen room as reserved and updates exam term"
            appCore -> notificationWorker "Publishes room-reserved event"
            notificationWorker -> mail    "Sends confirmation e-mail"
            teacher -> webApp             "Sees successful reservation message"
        }

        // ===== Deployment diagrams =====
        deployment healthExa "Dev/Test" "exaDevDeployment" {
            include *
        }

        deployment healthExa "Production" "exaProdDeployment" {
            include *
        }

        // ===== Styles =====
        theme default

        styles {
            element "Existing System" {
                background #999999
                color #ffffff
            }

            element "Database"  {
                shape Cylinder
            }
        }
    }
}