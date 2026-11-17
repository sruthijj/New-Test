"""
AWS Cloud Topology Dashboard
Flask server to run the application locally or with WSGI (gunicorn).
"""
import os
from flask import Flask, send_from_directory

app = Flask(__name__, static_folder='.', static_url_path='')

@app.route('/')
def index():
    return send_from_directory('.', 'index.html')

@app.route('/health')
def health():
    return {'status': 'healthy'}, 200

@app.route('/<path:path>')
def serve_static(path):
    return send_from_directory('.', path)

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 80))
    app.run(host='0.0.0.0', port=port)
