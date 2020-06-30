extends GridMap

var arr = {}
var deleted_arr = {}
var noise = OpenSimplexNoise.new()

const generation_start = -20
const generation_end = 21
const generation_height = 20
const generation_depth = -20

var temp_pos_condition = [
	Vector2(1, 0),
	Vector2(-1, 0),
	Vector2(0, 1),
	Vector2(0, -1)
]

var temp_width_condition = [
	Vector2(0, -1),
	Vector2(0, 1),
	Vector2(-1, 0),
	Vector2(1, 0)
]

var adjecent_chunks = [
	Vector3(0, 1, 0),
	Vector3(0, -1, 0),
	Vector3(0, 0, 1),
	Vector3(0, 0, -1),
	Vector3(1, 0, 0),
	Vector3(-1, 0, 0)
]

func _ready():
	randomize()
	noise.seed = randi()
	generate(Vector3(0,0,0), generation_start, generation_end)

func key_value(yy):
	var key
	if yy < 10:
		key = 3
	elif yy < 15 and yy >= 10:
		key = 1
	elif yy <= 20 and yy >= 15:
		key = 0
	else:
		print("something is wrong!!!")
	return key

func generate_water(pos):
	set_cell_item(pos.x, 2, pos.z, 2)
	arr[Vector2(pos.x, pos.z)][2] = 2

func Add(pos, start, end):
	var temp_pos
	var temp_posXZ
	var key_
	var y
	for i in range(start, end):
		for j in range(start, end):
			temp_posXZ = Vector2(pos.x, pos.z) + Vector2(i,j)
			if arr.has(temp_posXZ):
				for k in arr[temp_posXZ].keys():
					if k > generation_depth + pos.y and k < generation_height + pos.y:
						key_ = arr[temp_posXZ][k]
						if get_cell_item(i, k, j) == INVALID_CELL_ITEM:
							if deleted_arr.has(temp_posXZ) and k in deleted_arr[temp_posXZ].keys():
								pass
							else:
								temp_pos = Vector3(pos.x, 0, pos.z) + Vector3(i,k,j)
								set_cell_item(temp_pos.x, temp_pos.y, temp_pos.z, key_)
			else:
				y = noise.get_noise_2dv(temp_posXZ) * 10 + 10
				y = floor(y)
				temp_pos = Vector3(pos.x, 0, pos.z) + Vector3(i,y,j)
				key_ = key_value(y)
				
				set_cell_item(temp_pos.x, temp_pos.y, temp_pos.z, key_)
				arr[temp_posXZ] = {y:key_}
				

func Remove(pos, start, end):
	var temp_posXZ
	var temp_y
	for i in range(start, end):
		for k in range(4):
			temp_posXZ = Vector2(pos.x, pos.z) + (temp_pos_condition[k] * i) + (temp_width_condition[k] * (end-1))
			if arr.has(temp_posXZ):
				for j in arr[temp_posXZ].keys():
					if get_cell_item(temp_posXZ.x, j, temp_posXZ.y) != INVALID_CELL_ITEM:
						set_cell_item(temp_posXZ.x, j, temp_posXZ.y, INVALID_CELL_ITEM)
	
	for i in range(start, end):
		for k in range(start, end):
			temp_posXZ = Vector2(pos.x, pos.z) + Vector2(i, k)
			if arr.has(temp_posXZ):
				temp_y = pos.y + generation_height
				for j in arr[temp_posXZ].keys():
					if j > temp_y:
						if get_cell_item(temp_posXZ.x, j, temp_posXZ.y) != INVALID_CELL_ITEM:
							set_cell_item(temp_posXZ.x, j, temp_posXZ.y, INVALID_CELL_ITEM)
				
				temp_y = pos.y + generation_depth
				for j in arr[temp_posXZ].keys():
					if j < temp_y:
						if get_cell_item(temp_posXZ.x, j, temp_posXZ.y) != INVALID_CELL_ITEM:
							set_cell_item(temp_posXZ.x, j, temp_posXZ.y, INVALID_CELL_ITEM)

func generate(pos, start, end):
	Add(pos, start, end)
	
	start -= 1
	end += 1
	
	Remove(pos, start, end)

#func add_chunk(chnk, normal, key_):
#	var temp_pos = chnk.global_transform.origin + normal
#	var temp_posXZ = Vector2(temp_pos.x, temp_pos.z)
#	if arr.has(temp_posXZ):
#		if temp_pos.y in arr[temp_posXZ].keys():
#			if get_cell_item(temp_posXZ.x, temp_pos.y, temp_posXZ.y) == INVALID_CELL_ITEM:
#				set_cell_item(temp_posXZ.x, temp_pos.y, temp_posXZ.y, key_)
#				arr[Vector2(temp_pos.x, temp_pos.z)][temp_pos.y] = key_
#		else:
#			set_cell_item(temp_posXZ.x, temp_pos.y, temp_posXZ.y, key_)
#			arr[Vector2(temp_pos.x, temp_pos.z)][temp_pos.y] = key_
#
#	if deleted_arr.has(temp_posXZ):
#		if temp_pos.y in deleted_arr[temp_posXZ]:
#			if deleted_arr[temp_posXZ].size() < 1:
#				deleted_arr.erase(temp_posXZ)
#			else:
#				deleted_arr[temp_posXZ].erase(temp_pos.y)
#
#func chunk_deleted(chnk):
#	var pos = chnk.global_transform.origin
#	if deleted_arr.has(Vector2(pos.x, pos.z)):
#		deleted_arr[Vector2(pos.x, pos.z)].append(pos.y)
#	else:
#		deleted_arr[Vector2(pos.x, pos.z)] = [pos.y]
#
#	for i in range(6):
#		var temp_pos = pos + adjecent_chunks[i]
#		var temp_posXZ = Vector2(temp_pos.x, temp_pos.z)
#		if arr.has(temp_posXZ) and (temp_pos.y > arr[temp_posXZ].keys()[0] or (temp_pos.y in arr[temp_posXZ].keys())):
#			continue
#		if deleted_arr.has(temp_posXZ) and temp_pos.y in deleted_arr[temp_posXZ]:
#			continue
#
#		if arr.has(temp_posXZ):
#			if temp_pos.y in arr[Vector2(temp_pos.x, temp_pos.z)].keys():
#				var idx = arr[temp_posXZ][temp_pos.y][0]
#				var key_ = arr[temp_posXZ][temp_pos.y][1]
#				arr_instance.append(voxel[key_].instance())
#				add_child(arr_instance[idx])
#				arr_instance[idx].global_transform.origin = temp_pos
#			else:
#				var key_ = key_value(pos.y)
#				arr_instance.append(voxel[key_].instance())
#				add_child(arr_instance[index])
#				arr_instance[index].global_transform.origin = temp_pos
#				arr[temp_posXZ][temp_pos.y] = [index, key_]
#				index += 1
#
#	chnk.queue_free()
#	if arr.has(Vector2(pos.x, pos.z)):
#		if pos.y in arr[Vector2(pos.x, pos.z)].keys():
#			var idx = arr[Vector2(pos.x, pos.z)][pos.y][0]
#			arr_instance[idx] = 0
#
