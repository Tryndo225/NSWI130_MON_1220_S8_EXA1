# Exam Handling System

## Core features and responsibilities

### Feature: Student Exam Registration

**_As a_**  student registered in the system, 
**_I want_**  to be able to register into an exam through the system. 

**_So that_**  I can modify my exam schedule easily from anywhere.

#### Feature breakdown

**_Pre-conditions:_** 
- student has access and is logged into the school system with his school assigned email/ID

**_Main flow:_**
1. Student navigates to the exam sign in page. 
2. User provides information to the system (through the set UI) about the course he wishes to look up examination terms for.
3. The system parses this information by looking for the course in the "course database".
4. After the course was found, the system navigates to the course specific exam term schedule for this year, within the "examination timetable db".
5. The system displays the found information to the student.
6. The student chooses and selects the exam term which suits him most, then proceeds to confirm the choice by pressing the sign in button.
7. System verification (steps)
    1. First, the system checks that the student in fact is signed into the course he has selected, within the "student info db".
    2. The system checks, by using "student info db", that the student will not exceed the maximum registration count.
                   a. Student does exceed the maximum registration count - halt the process.
                   b. Student does not exceed the maximum registration count - go to the next step.
    3. Additionally, it ensures the student is not already registered for the same subject to a different term, by checking the "examination timetable db".
                   a. Student is registered to a different term of the same subject - request confirmation to continue registration and (after the registration is confirmed, step 8) sign out of the previous exam term.
                   b. Student is not registered to a different term of the same subject - go to the next step.
     4. Then, the system requests the "course db" for the information, whether the requirement for signing in the exam is having the course credit acquired.   
                   a. The course requires the student to have course credit acquired - the system check the "student info db" to ensure the student has credit for this course. 
                   b. The course does not require the student to have course credit acquired - the check passes automatically 
      5.  The system is signaled to check for capacity availability of the specific exam term within the "examination timetable db". 
      6.  After confirming there is available space, the system updates the list of students in the "examination timetable db" for this exam term. 
      7.  The system updates the list of signed examinations the student has (overall and for the specific course) within the "student info db".
8. When the system verifies the registration, it notifies the student that the registration was successful.
9. The student receives the notification of registration confirmation. 

**_Alternate flow:_**
4.a. The course was not found - the student is notified by the system of the nature of the mistake and the page goes back to the state before step 2
7.b If any step of verification fails - the student is notified by the system of the nature of the mistake and the page goes back to the state before step 5

**_Post-conditions:_**
- The student is registered to an exam term of his choosing.

#### Responsibilities

##### Exam Term Sign-In Page And Authentication Guard
- Serve the exam terms' sign-in page
- Ensure the student is authenticated
- Show the course lookup form

##### Course Lookup Input Handling 
- Capture the input from the UI
- Validate and sanitize the entered course identifier/name/partial name

##### Course Resolution In Course DB
- Search the "course db" for the course (code/name/year)
- Handle “course not found”

##### Term Schedule Retrieval 
- Query the timetable for this year’s terms of the found course
- Prepare data needed for display (dates, capacity, location)

##### Exam Term(s) Presentation
- Render the list of exam terms and their details
- Present controls to select a term and confirm

##### Exam Term Selection Capture
- Record/cache the selected term and explicit confirmation to register

##### Registration/Enrollment Verification
- Enrollment check "student info db" : verify the student is enrolled in the course; stop and inform if not
- Max registrations "student info db" : compare current count with limit; halt if exceeded
- Conflict check "exam timetable db" : detect registration to another term of the same subject; if found, ask for confirmation and plan deregistration of the previous term upon success (TODO - deregistration responsibility)
- Credit requirement "course db" - "student info db" : read whether credit is required; if yes, confirm the student has it
- Capacity check "exam timetable db" : verify available seats; protect against overbooking (lock/hold)

##### Outcome Notification/Alerting Responsibilities
- Recognize the process has ended (un)successfully or has been halted
- Generate appropriate message/alert/notification
- Trigger/show/send the alert/notification to the user/student (dashboard/email/mobile)

##### Notification/Alert Logging
- Record/log delivery status

### Feature: Reservation of Exam Premises

**_As a_**  professor registered in the system who has scheduled an exam,
**_I want_**  to be able make a reservation for a classroom for the exam. 

**_So that_**  I am guaranteed that it is free and available at the date and time of the exam.

#### Feature breakdown

**_Preconditions:_** 
Professor leading a course, which has at least one exam term scheduled, registered to the system. Referred to as "User".

**_Main Flow:_**
1. The system offers "user" all of his written out exam terms.
    a. The system connets to the online database.
    b. The system gets a list of all exam terms.
    c. The system filters the terms based on professors.
    d. The system shows user only the terms he has written out.
3. "User" opens a concrete exam term.
4. The system starts exam editor window and shows it to the "user".
5. "User" selects the room field.
6. The system checks the database for the availability of the school owned classrooms and displays available ones to the "user".
    a. The system connets to the online database.
    b. The system gets a list of all classrooms.
    c. The system filters the classrooms based on availability in the given time period.
    d. The system displays the filetered-out list to the user.
7. "User" selects his preferred classroom.
8. The system sets the classroom as unavailable for the exam's term time period and updates the database.
    a. The system connets to the online database.
    b. The system finds the selected classroom.
    c. The system marks the classroom as unavailable during the term's time period.
    d. The system finds the exam term currently being modified.
    e. The system updates the exam term's location to the selected classroom.
9. The system informs "user" of the successful classroom reservation.

**_Alternate Flow:_**
5b. "User" selects 'Other'.
6b. The system prompts the "user" to select a location.
    a. The system open a geographical map with a search bar.
    b. The system promps the user to select or find a prefered place.
7b. The system updates the exam's term location in the database.
    a. The system connets to the online database.
    b. The system finds the exam term currently being modified.
    c. The system updates the exam term's location to the selected location.
8b. The system informs the "user" of the success of the location update.

**_Postconditions:_** 
Professor has his selected exam's term location updated.

#### Responsibilities

##### Database Reading
- Connecting to the database.
- Reading the contents of the database.
- Fetching the contents to the client.

##### Database Modification
- Connecting to the database.
- Searching for item that has the modification.
- Updating set database item.
- Saving the database.

##### Database Filtering
- Connecting to the database.
- Reading the contents of the database.
- Applying filler to the contents.
- Fetching the filtered contents to the client.

##### Database Contents Display
- Fetching database contents.
- Creating a User-Friendly display window.
- Populating the display window with databse entries.

##### Mouse UI Input Handling
- Tracking the user mouse location.
- Notifing relevant UI elements of the mouse presses.

##### Diplaying Interactive Map Of Location
- Fetching the user current location.
- Finding the map of set location.
- Displaying the map for a user.
- Tracking user interaction with the map.

##### Action Process Status Notification
- Tracking the action process
- Generating a UI pop-up window
- Updating the window with relavant process status information

### Feature: Assigning Per-student Course Credit

**_As a_** professor registered in the system teaching a class,
For each of the students taking my course **_I want_**  to be able to flag whether they have acquired the course's credit or not. 

**_So that_** I can easily track who has credit and **_so that_** I don't have to manually inform the students one at the time.

### Feature: Assigning Per-Student Course Grade

**_As a_** teacher, leading a course, **_I want_** to be able to assign and modify students' course grades. 

**_So that_** the students may be timely notified and updated of their grade status.
