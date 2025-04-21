import flask
from flask import Flask, jsonify, request
import datetime

app = Flask(__name__)
# Disable JSON key sorting
app.json.sort_keys = False

@app.route('/')
def get_time():
    # Get the current timestamp
    timestamp = datetime.datetime.now().isoformat()
    # Get the IP address of the visitor
    ip = request.remote_addr
    # Return the JSON response
    return jsonify({
        'timestamp': timestamp,
        'ip': ip
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=4022, debug=True)