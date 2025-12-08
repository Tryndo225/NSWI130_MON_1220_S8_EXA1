
# Responsibilities Mapped to Containers and Components

---

## 1. Container: Enrollment Presenter

![](embed:enrollmentPresenterComponentDigram)

### Component: `courseTicketView`
**Feature: Student enrollment in lectures and practicals**
- Display available system features
- Display available lecture and practical tickets to a student
- Display the capacity of a given ticket
- Display a message to a student
- Allow selecting one lecture and one practical from a list of tickets


**Feature: Student enrollment cancellation**
- Display lecture/practical detail with cancel option
- Display cancellation confirmation
- Display cancellation success/error

**Feature: Student Enrollment Management**
- Display enrollment form
- Display tickets and unenroll option

---

### Component: `waitingListView`
**Feature: Student enrollment in lectures and practicals**
- Display waiting list position and max waiting time
- Display option to set maximum waiting time

---

### Component: `courseTicketController`
**Feature: Student enrollment in lectures and practicals**
- Enforce authenticated use
- Change UI based on input
- Handle UI selections
- Select lecture/practical
- Fetch tickets
- Verify enrollment

**Feature: Student enrollment cancellation**
- Fetch data for specific lecture/practical
- Propagate cancellation to backend

**Feature: Student Enrollment Management**
- Store enrollment / unenrollment for officers

---

### Component: `waitingListController`
**Feature: Student enrollment in lectures and practicals**
- Handle waiting list interactions
- Send join/leave/max-wait updates
- Get waiting list position

---

## 2. Container: Course Presenter

![](embed:coursePresenterComponentDiagram)

### Component: `courseSearch`
- Display course search UI
- Display list of matching courses

---

### Component: `courseSearchController`
- Extract user search input
- Perform search query in DB
- Fetch list of matching courses
- Close DB connections
- Cache course list

---

### Component: `courseOverview`
- Display course data
- Display student's enrolled courses

---

### Component: `courseOverviewController`
- Fetch course details
- Cache course data

---

## 3. Container: Student Information Presenter

![](embed:studentPresenterComponentDiagram)

### Component: `studentInfoView`
- Display student dashboard
- Display student schedule
- Display student info and enrolled courses

---

### Component: `studentInfoComponent`
- Fetch and cache student info
- Fetch and cache list of enrolled courses

---

### Component: `studentSearchView`
- Display list of students

---

### Component: `studentSearchComponent`
- Fetch and cache students
- Search students

---

## 4. Container: Conditions Presenter

![](embed:conditionsPresenterComponentDiagram)

### Component: `conditionListView`
- Display teacher’s courses
- Display existing conditions
- Display management options

---

### Component: `conditionSetterView`
- Display condition editor UI
- Display condition types
- Display forms and previews
- Display save/cancel and deletion confirmation

---

### Component: `conditionListController`
- SSO login for teachers
- Fetch teacher courses
- Fetch conditions
- Remove conditions
- Confirm deletions
- Enforce teacher authorization

---

### Component: `conditionSetterController`
- SSO login for teachers
- Fetch course data
- Fetch student attributes
- Persist new conditions
- Remove conditions
- Validate condition input

---

## 5. Container: SIS Messenger

![](embed:sisMessengerComponentDiagram)

### Component: `messageView`
- Display system-wide messages
- Display cancellation success/error

---

### Component: `messageController`
- Manage message retrieval

---

## 6. Container: Enrollment Manager

![](embed:enrollmentManagerComponeentDiagram)

### Component: `enrollmentAPI`
- Enforce authenticated enrollments
- Map SSO → student ID
- Change list of enrolled students
- Change student course info
- Sync course list with enrolled lists
- Add course to student
- Increase credits
- Add ticket to schedule
- Verify not yet enrolled
- Verify prerequisites
- Apply cancellation updates

---

### Component: `ticketCapacityHandler`
- Acquire write lock
- Check free capacity
- Increment attendee count
- Release lock
- Validate cancellation rules

---

### Component: `ticketStoreAdapter`
- Fetch all tickets
- Update waiting list
- Detect existing enrollment

---

### Component: `enrollmentWriter`
- Change enrollment in DB
- Change student course info
- Add course
- Increase credits
- Handle cancellations

---

### Component: `scheduleWriter`
- Add ticket to schedule
- Update schedule after cancellation

---

### Component: `waitQueueService`
- Add student to queue
- Set max waiting time
- Get waiting list position
- Dequeue
- Update waiting list

---

### Component: `auto-EnrollWorker`
- Remove students with exceeded waiting time
- Auto-enroll first from waiting list
- Trigger notifications

---

### Component: `conditionReader`, `predicateLibrary`, `conditionEvaluator`
- Verify prerequisites
- Evaluate single/multiple conditions
- Count satisfying/excluded students
- Summaries of exclusion reasons
- Enforce conditions
- Only enforce current conditions

---

## 7. Container: Conditions Manager

![](embed:conditionsManagerComponentDiagram)

### Component: `conditionManagementAPI`
- Fetch teacher courses
- Fetch/edit conditions
- Fetch condition types
- Store/remove conditions
- Validate input
- Enforce teacher authorization
- Map teacher SSO → teacher ID

---

### Component: `conditionSchema`
- Persist conditions
- Provide canonical current conditions

---

## 8. Container: Notification Service

![](embed:notificationServiceComponentDiagram)

### Component: `mailingListManager`
- Sign student to enrollment mailing list
- Sign student to waiting-list elimination list
- Manage officer-triggered notifications

---

### Component: `templateEngine`
- Build messages for enroll/unenroll/waitlist changes

---

### Component: `channelDispatcher`
- Send enrollment notifications
- Send unenrollment notifications
- Send waiting list notifications

---

### Component: `notificationDatabase`
- Store past notifications
- Store notification logs
- Load past notifications
- Load notification logs