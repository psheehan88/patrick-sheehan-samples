# Voice AI Assistant (Python + Speech + AI API)

This project is a **voice-enabled assistant prototype** that integrates:
- Speech recognition (microphone input)
- Natural language processing (AI API integration)
- Text-to-speech output (voice synthesis)
- Configurable commands (JSON-driven)

The assistant listens continuously, processes spoken commands/questions, and replies with
a spoken response. It also supports **custom command phrases** that trigger actions
on the host machine.

## Features
- **Speech-to-Text**: live microphone input → text commands
- **AI Integration**: forwards queries to AI API, returns natural responses
- **Text-to-Speech**: replies with a synthesized voice
- **Configurable Commands**: JSON file defines trigger phrases, responses, and actions
- **Looping / Exit Handling**: continuously runs until "exit" or "stop" command

## Example Flow
1. User: *"What's the weather today?"*  
2. Assistant:
   - Recognizes speech → text
   - Sends to AI → "The forecast today is sunny, high of 75."
   - Speaks response aloud with voice synthesis

Voice AI Assistant – Technology Overview
----------------------------------------

Core Language:
- Python 3.x

Speech Input:
- SpeechRecognition (microphone capture)
- PyAudio / system microphone drivers

Natural Language Processing:
- OpenAI API (chat/completions endpoint)
- JSON-based configuration for custom commands

Speech Output:
- eSpeak (lightweight TTS engine)
- Can be swapped for alternatives (Piper, pyttsx3, gTTS)

Configuration:
- config.json file defines:
  - Trigger phrases
  - Responses
  - Optional shell commands for automation

System Integration:
- OS-level actions via subprocess (open apps, run commands)
- Loop control (exit/stop/quit)
  
## Example Code Snippets

### `assistant.py` – Main Loop
```python
import speech_recognition as sr
import os, json
from openai import OpenAI
import subprocess

client = OpenAI()

def speak(text: str):
    # Example using espeak, replace with any TTS engine
    os.system(f'espeak -v en+f3 "{text}"')

def process_command(command: str, config: dict) -> bool:
    # Check against custom commands
    for phrase, action in config.items():
        if phrase in command.lower():
            if "response" in action:
                speak(action["response"])
            if "shell" in action:
                subprocess.Popen(action["shell"], shell=True)
            return True
    return False

def main():
    r = sr.Recognizer()
    config = json.load(open("config.json"))
    mic = sr.Microphone()

    speak("Assistant ready.")
    while True:
        with mic as source:
            audio = r.listen(source)
        try:
            command = r.recognize_google(audio)
            print("You said:", command)

            if command.lower() in ["exit", "stop", "quit"]:
                speak("Goodbye.")
                break

            if not process_command(command, config):
                # Default: send to AI
                resp = client.chat.completions.create(
                    model="gpt-4.1-mini",
                    messages=[{"role": "user", "content": command}]
                )
                answer = resp.choices[0].message.content
                print("AI:", answer)
                speak(answer)

        except Exception as e:
            print("Error:", e)

if __name__ == "__main__":
    main()


