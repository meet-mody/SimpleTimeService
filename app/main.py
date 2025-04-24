import flask
import os
from flask import Flask, jsonify, request
import datetime

app = Flask(__name__)
# Disable JSON key sorting
app.json.sort_keys = False

@app.route('/')
def get_time():
    """
    Returns the current timestamp and the IP address of the requester
    in JSON format.
    """
    # Get the current timestamp
    timestamp = datetime.datetime.now().isoformat()
    # Get the IP address of the visitor
    ip = request.remote_addr
    # Return the JSON response
    return jsonify({
        'timestamp': timestamp + " UTC",
        'ip': ip
    })

if __name__ == '__main__':
    """
    Starts the Flask application on the host 0.0.0.0 and port defined
    by the PORT environment variable (default is 8080).
    """
    app.run(debug=False, host='0.0.0.0', port=int(os.environ.get("PORT", 8080)))