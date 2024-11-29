import cv2
import dlib
import numpy as np
import time
import threading
import sounddevice as sd
from flask import Flask, Response
from flask_cors import CORS
import keyboard  # To detect ESC key press for stopping
from datetime import datetime  # For unique report filenames

# Global flags and variables
noisy_environment = False
stop_signal = False  # Stop signal flag
# Initialize Flask app
app = Flask(__name__)
CORS(app)

# Utility function to format time in hh:mm:ss format
def format_time(seconds):
    return time.strftime('%H:%M:%S', time.gmtime(seconds))

# Noise monitoring function
def check_ambient_noise():
    global noisy_environment, stop_signal
    while not stop_signal:  # Stop monitoring if stop_signal is True
        audio_sample = sd.rec(int(1 * 44100), samplerate=44100, channels=1, dtype='float64')
        sd.wait()
        rms = np.sqrt(np.mean(np.square(audio_sample)))
        decibel_level = 20 * np.log10(rms) if rms > 0 else 0
        noisy_environment = decibel_level > -45
        time.sleep(1)

# Generate session report with a unique filename
def generate_report(start_time, end_time, total_time, focused_time, distraction_time, timeline, was_noisy):
    # Generate a unique filename based on current timestamp
    timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    filename = f"study_session_report_{timestamp}.txt"
    
    # Calculate percentages
    focus_percentage = (focused_time / total_time) * 100 if total_time > 0 else 0

    # Write report data to the file
    with open(filename, "w") as report_file:
        report_file.write("Study Session Report\n")
        report_file.write("=====================\n")
        report_file.write(f"Start Time: {start_time.strftime('%Y-%m-%d %H:%M:%S')}\n")
        report_file.write(f"End Time: {end_time.strftime('%Y-%m-%d %H:%M:%S')}\n")
        report_file.write(f"Total Study Session Time: {format_time(total_time)}\n")
        report_file.write(f"Total Focused Time: {format_time(focused_time)}\n")
        report_file.write(f"Total Distraction Time: {format_time(distraction_time)}\n")
        report_file.write(f"Focus Percentage: {focus_percentage:.2f}%\n")
        report_file.write(f"Noisy Environment: {'Yes' if was_noisy else 'No'}\n\n")
        
        # Write focus and distraction timeline
        report_file.write("Focus and Distraction Timeline:\n")
        report_file.write("==============================\n")
        for entry in timeline:
            report_file.write(f"{entry['time']} - {entry['state']}\n")

    print(f"Session report saved as {filename}")

def generate_frames():
    global stop_signal
    detector = dlib.get_frontal_face_detector()
    predictor = dlib.shape_predictor(r"C:\Users\rudra\Desktop\shape_predictor_68_face_landmarks.dat")
    net = cv2.dnn.readNet(r"C:\Users\rudra\Desktop\yolov3.weights", r"C:\Users\rudra\Desktop\yolov3.cfg")
    layer_names = net.getLayerNames()
    output_layers = [layer_names[i - 1] for i in net.getUnconnectedOutLayers().flatten()]
    with open(r"C:\Users\rudra\Desktop\coco.names", 'r') as f:
        classes = [line.strip() for line in f.readlines()]
    book_class_id = 73  # Adjust as needed
    cap = cv2.VideoCapture(0)

    # Initialize variables
    focused_time = distraction_time = 0
    start_time = datetime.now()  # Start time of the session
    last_update_time = time.time() 
    timeline = []  # Timeline to log focus/distraction changes
    distraction_start = None  # Initialize to track the start time of distraction
    is_focused = False

    # Start noise monitoring in a separate thread
    threading.Thread(target=check_ambient_noise, daemon=True).start()

    while cap.isOpened() and not stop_signal:
        current_time = time.time()
        elapsed_since_update = current_time - last_update_time

        if keyboard.is_pressed('esc'):
            # stop_signal = True
            break

        # Update time metrics and record timeline entries
        if elapsed_since_update >= 1:
            if is_focused:
                focused_time += 1
            elif distraction_start and (current_time - distraction_start) >= 2:
                distraction_time += int(current_time - distraction_start)
                distraction_start = None  # Reset distraction tracking
            
            last_update_time = current_time

        ret, frame = cap.read()
        if not ret:
            break
        height, width, _ = frame.shape

        # Initialize detection variables
        book_detected = False
        face_detected = False

        # Face detection
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        faces = detector(gray)
        face_detected = len(faces) > 0

        for face in faces:
            x1, y1, x2, y2 = face.left(), face.top(), face.right(), face.bottom()
            cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)

        # Object detection (e.g., books)
        blob = cv2.dnn.blobFromImage(frame, 0.00392, (416, 416), (0, 0, 0), True, crop=False)
        net.setInput(blob)
        detections = net.forward(output_layers)

        for detection in detections:
            for obj in detection:
                scores = obj[5:]
                class_id = np.argmax(scores)
                confidence = scores[class_id]
                if confidence > 0.5 and class_id == book_class_id:
                    center_x, center_y = int(obj[0] * width), int(obj[1] * height)
                    w, h = int(obj[2] * width), int(obj[3] * height)
                    x, y = int(center_x - w / 2), int(center_y - h / 2)
                    cv2.rectangle(frame, (x, y), (x + w, y + h), (255, 0, 0), 2)
                    book_detected = True
                    break

        # Determine focus state
        previous_focus_state = is_focused
        is_focused = book_detected and face_detected
        if not is_focused and not distraction_start:
            distraction_start = current_time  # Start tracking distraction time
        
        # Log focus state change
        if is_focused != previous_focus_state:
            timeline.append({"time": datetime.now().strftime('%H:%M:%S'), "state": "Focused" if is_focused else "Distracted"})

        # Calculate and display metrics
        total_time = int((datetime.now()- start_time).total_seconds())
        formatted_focused_time = format_time(focused_time)
        formatted_distraction_time = format_time(distraction_time)
        formatted_total_time = format_time(total_time)

        cv2.putText(frame, "Focused" if is_focused else "Not Focused", (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 255), 2)
        cv2.putText(frame, f"Total Time: {formatted_total_time}", (10, 60), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2)
        cv2.putText(frame, f"Focused Time: {formatted_focused_time}", (10, 90), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 0), 2)
        cv2.putText(frame, f"Distraction Time: {formatted_distraction_time}", (10, 120), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 0, 255), 2)
        if noisy_environment:
            cv2.putText(frame, "Noisy Environment", (10, 150), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 0, 255), 2)

        # Encode frame as JPEG
        ret, buffer = cv2.imencode('.jpg', frame)
        frame = buffer.tobytes()

        # Stream frame as part of MJPEG stream
        yield (b'--frame\r\n' b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')
        time.sleep(0.5)
    cap.release()
    # Generate report when session ends
    end_time = datetime.now()
    total_time = int((end_time - start_time).total_seconds())
    was_noisy = noisy_environment  # Capture final noise status
    generate_report(start_time, end_time, total_time, focused_time, distraction_time, timeline, was_noisy)

cv2.destroyAllWindows()

@app.route('/video_feed')
def video_feed():
    return Response(generate_frames(), mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/stop_session', methods=['GET'])
def stop_session():
    global stop_signal
    stop_signal = True
    return "Session Stopped", 200

@app.route('/start_session', methods=['GET'])
def start_session():
    global stop_signal
    stop_signal = False
    return "Session Started", 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
