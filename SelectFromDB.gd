extends Node2D

var db = PostgreSQLClient.new()

var user = "postgres"
var password = "root123"
var host = "localhost"
var port = 5432
var dbConnection = "postgres"

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#db.connect("connection_established", self, "select_from_db")
	db.connect("authentication_error", self, "error")
	db.connect("connection_closed", self, "close_connection")
	db.connect_to_host("postgresql://%s:%s@%s:%d/%s" % [user, password, host, port, dbConnection])

func select_from_db() -> void:
	print("running select query")
	var datas = db.execute(
		"""
			BEGIN;
			SELECT * FROM users;
			commit;
		"""
	)
	
	for data in datas[1].data_row:
		print(data)

func create_record(id, name, password) -> void:
	print("running create query")
	var datas = db.execute(
		"""
			BEGIN;
			INSERT INTO users (id, name, created_at, password)
			values (%d, '%s', '%s', '%s');
			commit;
		""" % [id, name, strftime(OS.get_date()), password]
	)

func update_record(id, name, password) -> void:
	print("running update query")
	var datas = db.execute(
		"""
			BEGIN;
			UPDATE users
			SET name = '%s', password = '%s'
			WHERE id = '%d';
			commit;
		""" % [name, password, id]
	)

func delete_record(id) -> void:
	print("running update query")
	var datas = db.execute(
		"""
			BEGIN;
			DELETE FROM users
			WHERE id = '%d';
			commit;
		""" % id
	)

func strftime(value: Dictionary) -> String:
	return "%d-%02d-%02d" % [value.year, value.month, value.day]

func error() -> void:
	pass

func close_connection() -> void:
	print("database has closed!")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	db.poll()

func _exit_tree() -> void:
	db.close()


func _on_Button_button_up() -> void:
	create_record(1, "Saul", "root123")

func _on_Button2_button_up() -> void:
	select_from_db()

func _on_Button3_button_up() -> void:
	update_record(3, "Chichis Lindas", "Pezon Rosita")

func _on_Button4_button_up() -> void:
	delete_record(6)
