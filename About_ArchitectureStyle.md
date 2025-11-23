## Chosen architectural style – _Monolithic layered web application_

We model EXA as a monolithic system with a layered structure:

- presentation layer – web application container (all pages and UI components)
- application / business layer – application core container (registration workflow, room reservation, credits, grades, statistics)
- infrastructure layer – exam database (persistence) and Notification Worker (asynchronous e-mail sending)

We chose this style because:

- the system is relatively small, so a monolith keeps deployment and operations simple
- all features share the same domain model (courses, exam terms, students), so putting them into one codebase avoids premature splitting into microservices
- the layers correspond directly to the responsibilities we identified (UI vs business logic vs persistence/notifications), which improves maintainability (and somewhat matches the examples from the lecture)
