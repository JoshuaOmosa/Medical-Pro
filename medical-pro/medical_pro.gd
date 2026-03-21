extends Control

# UI Node References
@onready var input_field = $VBoxContainer/TranscriptInput
@onready var output_field = $VBoxContainer/OutputDisplay
@onready var http_request = $HTTPRequest

# --- API CONFIGURATION ---
# Replace this with the key you just got from AI Studio
var api_key = "REDACTED_API_KEY" 
var api_url = "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash-lite:generateContent?key=" + api_key

func _ready():
	# Connect signals
	$VBoxContainer/GenerateButton.pressed.connect(_on_generate_pressed)
	http_request.request_completed.connect(_on_request_completed)
	output_field.text = "System Ready (Gemini Engine). Enter transcript below."

func _on_generate_pressed():
	if input_field.text.strip_edges().is_empty():
		output_field.text = "Error: Input is empty."
		return
	
	output_field.text = "Engine: Processing Medical Transcript..."
	
	# 1. NEW 2026 STABLE ENDPOINT
	var prod_url = "https://generativelanguage.googleapis.com/v1/models/gemini-3.1-flash-lite:generateContent?key=" + api_key
	
	# 2. FORCE-TASK PROMPT (Prevents the "Please provide transcript" response)
	var system_command = "TASK: Convert transcript to SOAP note. FORMAT: Subjective, Objective, Assessment, Plan. "
	var force_output = "INSTRUCTION: Do not ask questions. Do not introduce yourself. Generate the note NOW. "
	var full_prompt = system_command + force_output + "\n\nTRANSCRIPT: " + input_field.text
	
	# 3. UPDATED JSON STRUCTURE
	var body = JSON.stringify({
		"contents": [{
			"parts": [{
				"text": full_prompt
			}]
		}],
		"generationConfig": {
			"temperature": 0.1, # Lower temperature = more professional/less chatty
			"maxOutputTokens": 1000
		}
	})
	
	var headers = ["Content-Type: application/json"]
	http_request.request(prod_url, headers, HTTPClient.METHOD_POST, body)

func _on_request_completed(_result, response_code, _headers, body):
	var response_string = body.get_string_from_utf8()
	var json = JSON.new()
	var parse_err = json.parse(response_string)
	
	if response_code == 200 and parse_err == OK:
		var data = json.get_data()
		# Gemini's response path: candidates -> content -> parts -> text
		if data.has("candidates") and data["candidates"].size() > 0:
			var content = data["candidates"][0]["content"]["parts"][0]["text"]
			output_field.text = content.strip_edges()
		else:
			output_field.text = "Error: Gemini returned an empty response."
	else:
		output_field.text = "API Error (" + str(response_code) + "): " + response_string