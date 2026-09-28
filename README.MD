# Medical-Pro

Convert doctor-patient transcripts into structured SOAP notes using Godot 4 and Google's Gemini API.

Just paste a transcript, click a button, get a formatted clinical note. That's it.

---

## What it does

You have a recording of a doctor and patient talking. You transcribe it. You paste it into Medical-Pro. It sends it to Gemini, gets back a SOAP note (Subjective, Objective, Assessment, Plan) that's already organized and ready to drop into an EHR.

No clicking around. No manual formatting. No "please provide more details."

---

## How to use it

### 1. Get the code
```bash
git clone https://github.com/yourusername/medical-pro.git
cd medical-pro
```

### 2. Get an API key
- Go to [aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey)
- Click "+ Create API Key"
- Copy it

### 3. Add your key to medical_pro.gd
Open `medical_pro.gd`, find line 6:
```gdscript
var api_key = "REDACTED_API_KEY"
```
Replace with yours.

### 4. Run it
Open the project in Godot 4.6+ and press ▶️

Paste a transcript. Click "Generate SOAP Note". Done.

---

## The workflow

```
Your Transcript
       ↓
[Paste into input field]
       ↓
[Click "Generate SOAP Note"]
       ↓
Sent to Gemini API
       ↓
AI extracts: symptoms → physical findings → diagnosis → treatment plan
       ↓
[SOAP note appears in output]
       ↓
Copy → Paste into EHR
```

---

## System architecture

```
Godot 4.6 (UI)
   ↓
medical_pro.gd (Logic)
   ↓
HTTPRequest (sends POST)
   ↓
Google Gemini 3.1 Flash-Lite API
   ↓
JSON response
   ↓
Parse & display
```

**Files that matter:**
- `medical_pro.gd` — The whole app. ~60 lines of GDScript.
- `control.tscn` — UI layout (TextEdit inputs, button, output field)

---

## Example

**Input (raw transcript):**
```
Doctor: What brings you in today?
Patient: I've had this cough for two weeks. It's dry, keeps me up at night.
Doctor: Any fever?
Patient: No, nothing like that. Temperature's been normal.
Doctor: Let me listen to your chest.
[sounds] 
Doctor: Lungs are clear. I think this is viral. Rest, fluids, honey for the cough.
Patient: How long should it last?
Doctor: Usually 3-4 weeks. Call if it gets worse or you develop a fever.
```

**Output (SOAP note):**
```
SUBJECTIVE:
Patient presents with 2-week history of dry cough, worse at night.
Denies fever. Temperature normal per patient report.
No dyspnea reported.

OBJECTIVE:
Vital signs: normal (per exam)
Lungs: clear to auscultation bilaterally

ASSESSMENT:
Viral upper respiratory infection / acute cough, likely viral etiology

PLAN:
1. Conservative management: rest, increased fluid intake
2. Recommend honey for symptomatic relief of cough
3. Return precautions: fever development, worsening symptoms, or symptoms
   lasting >3-4 weeks warrant return visit
```

That's what it does. Nothing fancy.

---

## Installation

**You need:**
- Godot 4.6 or newer
- Internet (for the API)
- A Gemini API key (free)

**Don't do:**
- Don't commit your API key to GitHub
- Use an environment variable instead:

```bash
export GEMINI_API_KEY="your_actual_key"
godot
```

Then in `medical_pro.gd`:
```gdscript
var api_key = OS.get_environment("GEMINI_API_KEY")
```

---

## Tuning

Open `medical_pro.gd`. Change these if you want:

```gdscript
# Line 20: How "creative" the AI is (0.1 = strict, 1.0 = loose)
"temperature": 0.1,

# Line 21: How long the response can be
"maxOutputTokens": 1000,
```

For a more detailed note, raise `maxOutputTokens` to 2000.
For stricter formatting, lower `temperature` to 0.05.

---

## API pricing

Gemini's free tier gives you 15 requests/minute, unlimited monthly.

If you hit that: ~$0.00005 per note. Not expensive.

[Check current pricing](https://ai.google.dev/pricing)

---

## Common issues

**"Error: Input is empty"**
You didn't paste anything. Paste a transcript first.

**"API Error (401)"**
Your key is wrong or expired. Get a new one from AI Studio.

**"Empty response"**
Transcript was too short or unclear. Try a longer example.

**Godot won't open the project**
You're on Godot 4.5 or older. Download 4.6+.

---

## Extending it

**Want PDF export?**
```gdscript
func save_note():
    var file = FileAccess.open("note.txt", FileAccess.WRITE)
    file.store_string(output_field.text)
```

**Want to send to an EHR API?**
Add another HTTPRequest and send the output to your EHR endpoint.

**Want batch processing?**
Loop over multiple transcripts and generate notes in sequence.

---

## What this is and isn't

**This is:**
- A tool for documentation. Saves time formatting.
- A starting point. Customize it for your workflow.

**This isn't:**
- A medical device. Verify AI output with a real clinician.
- HIPAA-compliant out of the box. Godot doesn't encrypt data at rest. Add that if you need it.
- A replacement for clinical judgment. The AI can miss things.

---

## Stack

- **Engine:** Godot 4.6
- **Language:** GDScript
- **API:** Google Gemini 3.1 Flash-Lite
- **HTTP:** Godot's built-in HTTPRequest node

---

## License

MIT. Use it. Fork it. Change it. Just include the license.

---

## Questions?

- Bugs: [GitHub Issues](https://github.com/yourusername/medical-pro/issues)
- Godot help: [docs.godotengine.org](https://docs.godotengine.org)
- Gemini API: [ai.google.dev/docs](https://ai.google.dev/docs)

---

Made by someone who wanted faster clinical notes.