from collections import defaultdict
from flask import Flask, render_template, request, redirect, url_for
from services import Database

app = Flask(__name__)
db = Database()


# TODO:
# - replace redirect with abort with providing special information
# - add index page for non logged users
# - add user page
# - pass context to templates, not user, users and etc..
# - update users list only on good responses
 
class User():
	def __init__(self, user_data) -> None:
		self.id = user_data[0]
		self.name = user_data[1]
		self.surname = user_data[2]
		self.date_of_birth = user_data[3]
		self.personal_link = user_data[4]
		self.phone_number = user_data[5]
		self.email = user_data[6]
		self.city = user_data[7]
		self.additional_info = user_data[8]
		self.access_level = user_data[9]
		self.position_id = user_data[10]
		self.activity_points = user_data[11]
		self.last_promotion_date = user_data[12]
		self.hire_date = user_data[13]
		self.fire_date = user_data[14]
		self.fire_reason = user_data[15]
		self.archived = user_data[16]
		self.departament_head_or_dep = False
		self.can_hire = False
		self.can_promote = False
		self.can_fire = False
		self.can_create_departaments = False
		self.can_view_profiles = False
		self.can_register_activities = False
		self.set_values()
	

	def set_values(self) -> None:
		self.set_permissions()
		self.set_departament()


	def set_permissions(self) -> None:
		bad_format = db.get_permissions_list(self.id)
		permissions = []
		for i in bad_format:
			permissions.append(i[0])
		print(permissions)
		if 4 in permissions:
			self.can_promote = True
		if 5 in permissions:
			self.can_hire = True
		if 6 in permissions:
			self.can_fire = True
		if 10 in permissions:
			self.can_register_activities = True
		if 12 in permissions:
			self.can_create_departaments = True
		if 13 in permissions:
			self.can_view_profiles = True
	
	def set_departament(self) -> None:
		if self.access_level != 0:
			self.departament_head_or_dep = db.is_departament_head_or_deputy(self.id)




#current_user = None
#current_user = User(db.login(email = "i.lazuk@bk.ru", password = "1234"))

# temp data
current_user = User(db.login(email = "alex_filatov@mycompany.com", password = "123")) 
users = None
# temp data


def set_users(users_data: list):
	global users
	users = defaultdict()
	for user_data in users_data:
		new_user = User(user_data)
		users[new_user.id] = new_user


set_users(db.employees_list()) # temp

@app.after_request
def update_users(response):
	set_users(db.employees_list())
	return response


@app.route("/")
def index():
	if current_user:
		set_users(db.employees_list())
		return render_template('index.html', user=current_user, users=users)
	else:
		return render_template('index.html')


@app.route("/register", methods = ["GET", "POST"])
def register():
	if current_user:
		return redirect(url_for('index'))
	error = None
	if request.method == "POST":
		if not db.register(	
			email = request.form["email"], 
			name = request.form["name"],
			surname = request.form["surname"],
			date = request.form["date"],
			link = request.form["link"],
			phone = request.form["phone"],
			city = request.form["city"],
			additional = request.form["additional"],
			password = request.form["password"]
			):
			error = f"Account with email {request.form['email']} is already exist"
		else:
			return redirect(url_for('login', email = request.form["email"], password = request.form["password"]))

	return render_template('register.html', error=error, request=request)


@app.route("/login", methods = ["GET", "POST"])
def login(email = "", password = ""):
	global current_user
	if current_user:
		return redirect(url_for("index"))
	error = None
	email = request.form.get("email", "")
	password = request.form.get("password", "")
	if request.method == "POST":
		user_data = db.login(email = request.form["email"], password = request.form["password"])
		print(user_data)
		if user_data == None:
			error = "Check your login data!"
		else:
			current_user = User(user_data)
			set_users(db.employees_list())
			return redirect(url_for("index"))

	return render_template('login.html', email=email, password=password, error=error)
	
@app.route("/logout")
def logout():
	global current_user
	current_user = None
	return redirect(url_for('login'))


@app.route("/hire/<user_id>")
def hire(user_id: int):
	if not current_user:
		return redirect(url_for("index"))
	if not current_user.can_hire:
		return redirect(url_for("index", error="You can't hire other people with your permissions"))
	if users[int(user_id)].access_level != 0:
		return redirect(url_for("index", error="You can't hire employee with access level != 0"))
	db.hire_user(current_user.id, user_id)
	return redirect(url_for('index'))

	
	
@app.route("/promote/<user_id>")
def promote(user_id: int):
	if not current_user:
		return redirect(url_for("index"))
	if not current_user.can_promote:
		return redirect(url_for("index", error="You can't promote other people with your permissions"))
	if current_user.access_level - 1 <= users[int(user_id)].access_level:
		return redirect(url_for("index", error="You can't promote employee to your access level or higher"))
	db.promote_user(current_user.id, user_id)
	return redirect(url_for('index'))



@app.route("/fire/<user_id>", methods = ["POST"])
def fire(user_id: int):
	reason = request.form["fire_reason"]
	if not current_user:
		return redirect(url_for("index"))
	if not current_user.can_fire:
		return redirect(url_for("index", error="You can't fire other people with your permissions"))
	if current_user.access_level <= users[int(user_id)].access_level:
		return redirect(url_for("index", error="You can't fire employee with equal or higher access level"))
	db.fire_user(current_user.id, user_id, reason)
	return redirect(url_for('index'))


@app.route("/departaments", methods = ["GET", "POST"])
def departaments():
	error = None
	if not current_user:
		return redirect(url_for("index"))
	if request.method == "POST":
		if request.form.get("dep_deputy") == request.form.get("dep_head"):
			error = "Head and deputy must be different employees."
		else:
			db.new_departament(current_user.id, request.form["dep_name"], int(request.form["dep_head"]), int(request.form["dep_deputy"]))
			return redirect('departaments')

	return render_template("departaments.html", user = current_user, departaments = db.get_departaments(), users=users, error=error)


@app.route("/ticket", methods = ["POST"])
def ticket():
	pass


@app.route("/profile/<id>")
def profile(id: int):
	id = int(id)
	if not current_user:
		return redirect(url_for("index"))
	if not current_user.can_view_profiles:
		return redirect(url_for('index'))
	if current_user.access_level < users[id].access_level:
		return redirect(url_for("index")) 
	logs = None
	if current_user.can_register_activities:
		logs = db.get_user_logs(id)
	activities = None 
	if current_user.can_register_activities:
		activities = db.get_user_activities(id)
	return render_template("profile.html", user = current_user, _user = users[id], logs = logs, users = users, activities=activities)

@app.route("/activity/<id>", methods = ["POST"])
def activity(id: int):
	id = int(id)
	if not current_user:
		return redirect(url_for("index"))
	if not current_user.can_register_activities:
		return redirect(url_for('index'))
	if current_user.access_level <= users[id].access_level:
		return redirect(url_for("index")) 
	db.register_activity(current_user.id, id, request.form["activity_id"])
	return redirect(url_for('profile', id=id))
	