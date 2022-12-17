import datetime
import psycopg2

class Database():
	def __init__(self) -> None:
		self.__connection = psycopg2.connect(host = "localhost", database = "personnelcontrol", user = "postgres", password = "123")
		self._cursor = self.__connection.cursor()
		#self.__test_connection()


	def register(self, email: str, name: str, surname: str, date: datetime.date, link: str, phone: str, city: str, password: str, additional = "") -> bool:
		if self.user_exist(email):
			return False
		self._cursor.execute(f"""
		INSERT INTO employees (name, surname, date_of_birth, personal_link, phone_number, email, city, additional_info, pass_hash, hire_date) VALUES
		('{name}', '{surname}', '{date}', '{link}', '{phone}', '{email}', '{city}', '{additional}', crypt('{password}', gen_salt('bf')), '{datetime.date.today()}')
		""")
		print(self._cursor.statusmessage)
		if "INSERT" in self._cursor.statusmessage:
			self.__connection.commit()
			return True
		else:
			return False
	

	def user_exist(self, email: str) -> bool:
		self._cursor.execute(f"""
		SELECT * from employees WHERE email = '{email}'
		""")
		# if no rows returned
		print(self._cursor.fetchone())
		if self._cursor.fetchone():
			return True
		else:
			return False


	def login(self, email: str, password: str) -> tuple | None:
		self._cursor.execute(f"""
		SELECT * from employees WHERE email = '{email}' and pass_hash = crypt('{password}', pass_hash);
		""")
		#print(self._cursor.fetchone())
		return self._cursor.fetchone()


	def employees_list(self) -> bool:
		self._cursor.execute(f"""
		SELECT * from employees
		ORDER BY access_level desc;
		""")
		return self._cursor.fetchall()

	
	def get_permissions_list(self, id: int) -> tuple:
		self._cursor.execute(f"""
		SELECT permission_id FROM projects_permissions, employees_projects, permissions
		WHERE employees_projects.project_id = projects_permissions.project_id AND employees_projects.employee_id = {id}
		AND projects_permissions.permission_id = permissions.id
		UNION
		SELECT DISTINCT permission_id FROM access_levels_permissions, permissions, employees
		WHERE access_levels_permissions.access_level = (SELECT access_level FROM employees WHERE id = {id})
		AND access_levels_permissions.permission_id = permissions.id;
		""")
		return tuple(self._cursor.fetchall())
	

	def hire_user(self, initiator_id: int, affected_id: int) -> None:
		self._cursor.execute(f"""
		CALL employee_hired({initiator_id}, {affected_id})
		""")
		self.__connection.commit()

	def promote_user(self, initiator_id: int, affected_id: int) -> None:
		self._cursor.execute(f"""
		CALL employee_promoted({initiator_id}, {affected_id})
		""")
		self.__connection.commit()

	def fire_user(self, initiator_id: int, affected_id: int, reason: str) -> None:
		self._cursor.execute(f"""
		CALL employee_fired({initiator_id}, {affected_id}, '{reason}')
		""")
		self.__connection.commit()
	

	def get_departaments(self):
		self._cursor.execute(f"""
		SELECT * FROM departaments;
		""")
		return self._cursor.fetchall()


	def is_departament_head_or_deputy(self, user_id: int):
		self._cursor.execute(f"""
		SELECT * FROM departaments WHERE head_id = {user_id} OR deputy_head_id = {user_id};
		""")
		return not self._cursor.fetchone() == None


	def new_departament(self, initiator_id: int, name: str, head_id: int, deputy_head_id = -1) -> None:
		self._cursor.execute(f"""
		CALL new_departament({initiator_id}, '{name}', {head_id}, {deputy_head_id})
		""")
		self.__connection.commit()


	def __test_connection(self):	
		self._cursor.execute("SELECT * FROM employees WHERE name = 'Alex'")
		for query in self._cursor:
			print(str(query))
