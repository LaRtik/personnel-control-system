# Personnel Control System (PostgreSQL)
**System that helps you control your organization personnel**
> Ilya Lazuk, 053505

## Functional features
- User registration and authorization.
- Each user (employee) has it's own **access level** and main **position**. First registered user will get max Access level automatically. Also, any employee could have **any additional projects** in departaments. 
- Registration is available for everyone. However, after the registration each user (employee) has access level 0 (which has no permissions) by default. Any employee from management team (starting with access level N) man set higher access level for the employee (setting access level must be strictle lower than access level of management team employee). 
- **Departaments** may be created by management team (highest Access levels). Departament has it's head employee (optionally deputy head employee). Each employee may be head only of one departament at the same time.
- Each access level and project has it's own **list of permissions**.
- Starting with Access level N (can be set in config file) employee can edit, promote or fire any other employee with lower Access level (*aka management departament*). Starting with Access level M (can be set in config file) employee can fine or reward **(Tickets system)** any other employee with lower Access level. Each ticket has it's own salary penalty / bonus.
- **Activity points**. During work process each employee gets ActivityTicket. Each ActivityTicket has it's description and number of points granted to the owner of this ticket (employee). Taking into account this tickets Management departament may reward / fine / promote / fire employees. Fired employees marked as archived.
- **Loggin system**. Any action of any employee is logged (LOG table).

## Database model
![Database model](https://user-images.githubusercontent.com/36516154/199718191-73eda713-8ad0-478a-98b3-f332f9f481c1.png)
