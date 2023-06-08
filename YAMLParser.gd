extends Node

class_name YAMLParser

var parsedData := {}

func load(path):
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	return content

func parse_yaml_file(file_path: String) -> Dictionary:
	
	#Load YAML into memory
	var YAML_file := FileAccess.open(file_path, FileAccess.READ).get_as_text()
	
	if YAML_file.is_empty():
		print("Failed to open file: ", file_path)
		return {}
	
	
	# Remove comments from the YAML text
	var yaml_text := remove_comments(YAML_file)
	
	# Split the YAML text into separate lines
	var lines := yaml_text.split("\n")
	
	var current_indentation := 0
	var current_dict := parsedData
	
	for line in lines:
		# Skip empty lines
		if line.strip_edges().is_empty():
			continue
		
		var indentation := line.length() - line.lstrip().length()
		var line_content := line.trim().to_lower()
		
		# Handle indentation changes
		if indentation > current_indentation:
			print("Indentation error: unexpected increase in indentation.")
			return {}
		elif indentation < current_indentation:
			var diff := current_indentation - indentation
			for i in range(diff / 2):
				current_dict = current_dict["__parent__"]
			current_indentation = indentation
		
		# Parse key-value pairs
		if line_content.endswith(":"):
			var key := line_content.rstrip(":")
			current_dict[key] = {}
			current_dict[key]["__parent__"] = current_dict
			current_dict = current_dict[key]
		else:
			var parts := line_content.split(":")
			if parts.size() != 2:
				print("Syntax error: invalid key-value pair in line: ", line)
				return {}
			
			var key := parts[0].strip_edges()
			var value := parts[1].strip_edges()
			current_dict[key] = value
	
	return parsedData

func remove_comments(yaml_text: String) -> String:
	var lines := yaml_text.split("\n")
	for i in range(lines.size()):
		var line := lines[i]
		var comment_index := line.find("#")
		if comment_index != -1:
			lines[i] = line.substr(0, comment_index)
	return lines.join("\n")
