extends Control

var overflow_counter = 50000

func _ready():
	get_tree().call_group("solution", "hide")
	$"%PuzzleText".text = "..32....6....4..9.1.2...5..7...29....4.3.7.5....81...2..1...8.3.2..8....9....46"


func _on_SolveButton_pressed():
	var numbers = parse_puzzle_text()
	var output = []
	var digits = "123456789";
	var candidates = []
	candidates.resize(81)
	candidates.fill(digits)
	var grid = []
	grid.resize(81)
	for idx in 81:
		# Add initial numbers to the grid
		grid[idx] = int(numbers[idx])
		# Remove number from peer cell candidates
		if grid[idx] > 0:
			removeNumberFromPeers(idx, numbers[idx], candidates)
	var start_time = Time.get_ticks_msec()
	var solved = solve(-1, candidates, grid) && overflow_counter > 0
	output.append("Running time: %dms" % [Time.get_ticks_msec() - start_time])
	if not solved:
		grid = []
		output.append("Unsolveable puzzle!")
	show_solution(grid, output)

func solve(idx, candidates, grid):
	overflow_counter -= 1
	# Check for completion
	if not grid.has(0) || overflow_counter < 1: return true
	# Find the next empty grid cell with the least number of possible candidates
	var cell_idx = -1
	var num_candidates = 10
	while(true):
		idx = getNextEmptyCell(idx, grid)
		if cell_idx == idx: break
		if candidates[idx].length() < num_candidates:
			cell_idx = idx
			num_candidates = candidates[idx].length()
	# Apply number candidates to the grid cell
	for i in num_candidates:
		var n = candidates[idx][i];
		grid[idx] = int(n)
		var cand_copy = candidates.duplicate()
		# If removing the number from peers results in no candidates left for
		# a cell then a dead end was reached
		removeNumberFromPeers(idx, n, cand_copy)
		# Recursive call. Unwinds with true if a solution is reached.
		if solve(idx, cand_copy, grid): return true
	# Clear the failed candidate from the grid
	grid[idx] = 0
	return false


func getNextEmptyCell(idx, grid):
	while(true):
		idx = (idx + 1) % 81
		if grid[idx] == 0: return idx


func removeNumberFromPeers(idx, n, candidates):
	var x = idx % 9 # Position along row
	var y = int(idx / 9) * 9 # Position along column
	var bx = int(x / 3) * 3 # Box horizontal corner position
	var by = int(idx / 27) * 27 # Box vertical corner position
	for p in 9:
		# Column
		candidates[x + p * 9] = candidates[x + p * 9].replace(n, '')
		# Row
		candidates[y + p] = candidates[y + p].replace(n, '')
	# Box
	for p in 3:
		for k in 3:
			candidates[bx + k + by] = candidates[bx + k + by].replace(n, '')
		by += 9;


func parse_puzzle_text():
	return $"%PuzzleText".text.replace('.', '0').rpad(81, '0')


func show_solution(grid, output):
	$"%Solution".text = array_to_string(grid, '')
	$"%Output".text = array_to_string(output)
	get_tree().call_group("solution", "show")


func array_to_string(arr, delimiter = "\n"):
	var s = PackedStringArray()
	for n in arr:
		s.append(str(n))
	return delimiter.join(s)


func debug(grid, candidates):
	for row in 9:
		var rv = []
		for col in 9:
			rv.append(grid[row * 9 + col])
		print(rv)
	print('---')
	for row in 9:
		var rv = []
		for col in 9:
			rv.append(candidates[row * 9 + col])
		print(rv)
