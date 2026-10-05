extends Control

# UI Node References
@onready var input_field = $VBoxContainer/TranscriptInput
@onready var output_field = $VBoxContainer/OutputDisplay
@onready var http_request = $HTTPRequest

# --- API CONFIGURATION ---
# The key is read from the GEMINI_API_KEY environment variable at runtime so it
# never ends up in source control. Set it before launching Godot, e.g.
#   PowerShell:  $env:GEMINI_API_KEY = "your_key"
#   bash/zsh:    export GEMINI_API_KEY="your_key"
const MODEL := "gemini-3.1-flash-lite"
const API_URL := "https://generativelanguage.googleapis.com/v1/models/%s:generateContent" % MODEL

var api_key: String = OS.get_environment("GEMINI_API_KEY")

func _ready():
	# Connect signals
	$VBoxContainer/GenerateButton.pressed.connect(_on_generate_pressed)
	http_request.request_completed.connect(_on_request_completed)
	if api_key.is_empty():
		output_field.text = "GEMINI_API_KEY is not set. Set it and restart the app."
	else:
		output_field.text = "System Ready (Gemini Engine). Enter transcript below."

func _on_generate_pressed():
	if api_key.is_empty():
		output_field.text = "Error: GEMINI_API_KEY is not set."
		return
	if input_field.text.strip_edges().is_empty():
		output_field.text = "Error: Input is empty."
		return
	
	output_field.text = "Engine: Processing Medical Transcript..."
	
	# Tell the model exactly what to produce so it doesn't reply with questions
	# or ask for the transcript again.
	var system_command = "TASK: Convert transcript to SOAP note. FORMAT: Subjective, Objective, Assessment, Plan. "
	var force_output = "INSTRUCTION: Do not ask questions. Do not introduce yourself. Generate the note NOW. "
	var full_prompt = system_command + force_output + "

TRANSCRIPT: " + input_field.text
	
	var body = JSON.stringify({
		"contents": [{
			"parts": [{
				"text": full_prompt
			}]
		}],
		"generationConfig": {
			"temperature": 0.1, # Lower temperature = more consistent, less chatty output
			"maxOutputTokens": 1000
		}
	})
	
	# Sending the key as a header keeps it out of URLs and request logs.
	var headers = ["Content-Type: application/json", "x-goog-api-key: " + api_key]
	http_request.request(API_URL, headers, HTTPClient.METHOD_POST, body)

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