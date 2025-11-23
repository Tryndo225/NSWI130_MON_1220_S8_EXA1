## Mapping responsibilities to C4 elements

### Feature 1 – Student Exam Registration

| Responsibility group | Container(s) | Component(s) | Notes |
| --- | --- | --- | --- |
| **Exam Term Sign-In Page and Authentication Guard** – serve exam sign-in page, ensure student is authenticated, show course lookup form | Web Application | Login Page & Auth Guard; Exam Registration Page | Login page checks identity; registration page shows the course lookup UI once the user is authenticated. |
| **Course Lookup Input Handling** – capture input, basic validation/sanitisation | Web Application; Application Core | Exam Registration Page; Course Lookup Service | Page captures the raw input; the service validates and normalises it before querying. |
| **Course Resolution in Course DB** – find course, handle “course not found” | Application Core; Exam Database | Course Lookup Service; Exam Repository | Lookup service coordinates; repository actually talks to the DB. Error is surfaced back to the UI. |
| **Term Schedule Retrieval** – query timetable for course terms this year, prepare data for display | Application Core; Exam Database | Exam Term Query Service; Exam Repository | Query service builds the query & view model; repository reads exam terms and capacities. |
| **Exam Term(s) Presentation** – render list of terms and controls | Web Application | Exam Registration Page | Shows term list, capacities, locations and “sign in” buttons. |
| **Exam Term Selection Capture** – record selected term and confirmation | Web Application | Exam Registration Page | Stores the chosen term ID and sends it to the backend when user confirms. |
| **Registration / Enrollment Verification – enrolment check** – verify student is enrolled in the course | Application Core; SIS; Exam Database | Eligibility Check Service; Exam Repository | Eligibility service checks SIS / student data (enrolment) via repository and external SIS adapter. |
| **Registration / Enrollment Verification – max registration count** – ensure student won’t exceed allowed attempts | Application Core; Exam Database | Eligibility Check Service; Exam Repository | Counts existing registrations for the student + course. |
| **Registration / Enrollment Verification – conflict check** – detect registration to another term of the same subject | Application Core; Exam Database | Eligibility Check Service; Exam Term Query Service; Exam Repository | Uses timetable data to detect overlapping registrations for same course. |
| **Registration / Enrollment Verification – credit requirement** – check whether course requires credit and whether the student has it | Application Core; SIS/Exam Database | Eligibility Check Service; Exam Repository | Reads course requirements/credits and checks student’s record. |
| **Registration / Enrollment Verification – capacity check & reservation** – verify free seats and protect against overbooking | Application Core; Exam Database | Capacity Check Service; Exam Repository | Performs capacity check and updates the term’s occupied-seats atomically. |
| **Registration / Enrollment Verification – update registration info** – update timetable and student’s list of signed exams | Application Core; Exam Database | Exam Repository | Inserts/updates rows in registrations + links to exam term and student. |
| **Outcome Notification / Alerting** – recognise success/failure, show or send notification | Web Application; Notification Worker; Email system | Notification Widget; Notification Facade; Registration Notifier; Email Sender | Widget shows on-screen messages. Facade creates domain event; notifier builds e-mail; sender pushes it via school mail system. |
| **Notification / Alert Logging** – record/log delivery status | Notification Worker; Exam Database | Notification Log | Persists metadata about notifications (what was sent and whether delivery succeeded). |

### Feature 2 – Reservation of Exam Premises

| Responsibility group | Container(s) | Component(s) | Notes |
| --- | --- | --- | --- |
| **Database Reading** – connect to DB, read all exam terms / classrooms, fetch data to client | Application Core; Exam Database | Exam Term Query Service; Room Availability Service; Exam Repository | Query service reads professor’s exam terms; room availability service reads classrooms and their planned occupancy; repository manages the actual DB access. |
| **Database Modification** – search for the item to modify, update it, save DB | Application Core; Exam Database | Room Reservation Service; Exam Repository | Room reservation service finds the chosen exam term and classroom and updates both the term’s location and the room’s availability. |
| **Database Filtering** – filter terms by professor; filter classrooms by availability for given time period | Application Core; Exam Database | Exam Term Query Service; Room Availability Service | First filters exam terms to “terms created by this professor”; then filters classrooms to “free in exam’s time slot”. |
| **Database Contents Display** – user-friendly window with exam terms / rooms | Web Application | Exam Term Management Page; Room Reservation Page | Exam Management Page shows list of professor’s exam terms; Room Reservation Page shows the available classrooms or the “Other location” option. |
| **Mouse UI Input Handling** – track mouse, notify UI elements about clicks | Web Application | Exam Term Management Page; Room Reservation Page | Pages handle row selection, opening editor, selecting a room / ‘Other’ option via common UI/mouse event handling. |
| **Displaying Interactive Map of Location** – show map, track user interaction, pick external location | Web Application | Room Reservation Page | This page embeds an interactive map (e.g. via JS map widget) and tracks user’s click/selection for an external location. In C4 we keep the map provider implicit; if needed it could become an external “Map Provider API” system later. |
| **Action Process Status Notification** – track progress, show pop-up, update status | Web Application; Notification Worker | Notification Widget; Room Reservation Notifier; Email Sender; Notification Log | For immediate feedback the Notification Widget shows inline pop-ups; on successful reservation the worker sends an e-mail (Room Reservation Notifier + Email Sender) and logs it (Notification Log). |
