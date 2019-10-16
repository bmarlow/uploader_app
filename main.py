import os
# import magic
import urllib.request
import shutil, kafka, logging, subprocess
from app import app
from flask import Flask, flash, request, redirect, render_template, abort, send_file, jsonify
from werkzeug.utils import secure_filename

ALLOWED_EXTENSIONS = set(['npy', 'h5'])


def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


@app.route('/')
def upload_form():
    return render_template('upload.html')


@app.route('/file-list', defaults={'req_path': ''})
@app.route('/file-list/<path:req_path>')
def dir_listing(req_path):
    BASE_DIR = '/tmp/processed'

    # Joining the base and the requested path
    abs_path = os.path.join(BASE_DIR, req_path)

    # Return 404 if path doesn't exist
    if not os.path.exists(abs_path):
        return abort(404)

    # Check if path is a file and serve
    if os.path.isfile(abs_path):
        return send_file(abs_path)

    # Show directory contents
    files = os.listdir(abs_path)
    return render_template('file-list.html', files=files)


@app.route('/', methods=['POST'])
def upload_file():
    if request.method == 'POST':
        # check if the post request has the files part
        if 'files[]' not in request.files:
            flash('No file part')
            return redirect(request.url)
        files = request.files.getlist('files[]')
        for file in files:
            if file and allowed_file(file.filename):
                filename = secure_filename(file.filename)
                file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
                enc_message = bytes('The following file was received: ' + file.filename + '', encoding='utf-8')
                producer.send('file-received', enc_message)
            else:
                return render_template('naughty.html')
            
        flash('File(s) successfully uploaded')
        return redirect('/')


@app.route('/pre-staged', methods=['POST'])
def stage_files():
    if request.method == 'POST':
        shutil.copy("/tmp/data/X.npy", "/tmp/uploads/X.npy")
        shutil.copy("/tmp/data/y.npy", "/tmp/uploads/y.npy")
        producer.send('file-received', b'The following file was received: X.npy')
        producer.send('file-received', b'The following file was received: y.npy')
        flash('Staging files used')
        return redirect('/')


@app.route("/files/<path>", methods=['GET'])
def download_files(path):
    if path is None:
        abort(400, 'empty path not allowed')
    try:
        return send_file('/tmp/uploads/' + path, as_attachment=True)
    except Exception as e:
        abort(404, 'file not found, sorry')

    flash('File downloaded')
    return redirect('/')


@app.route("/processed/<path>", methods=['GET'])
def download_processed_files(path):
    if path is None:
        abort(400, 'empty path not allowed')
    try:
        return send_file('/tmp/processed/' + path, as_attachment=True)
    except Exception as e:
        abort(404, 'file not found, sorry')

    flash('File downloaded')
    return redirect('/')


@app.route('/api-upload', methods=['POST'])
def api_upload_file():
    # check if the post request has the file part
    if 'file' not in request.files:
        resp = jsonify({'message' : 'No file part in the request'})
        resp.status_code = 400
        return resp
    file = request.files['file']
    if file.filename == '':
        resp = jsonify({'message' : 'No file selected for uploading'})
        resp.status_code = 400
        return resp
    if file and allowed_file(file.filename):
        filename = secure_filename(file.filename)
        file.save(os.path.join('/tmp/processed', filename))
        resp = jsonify({'message' : 'File successfully uploaded'})
        resp.status_code = 201
        return resp
    else:
        resp = jsonify({'message' : 'Allowed file types are txt, pdf, png, jpg, jpeg, gif'})
        resp.status_code = 400
        return resp


@app.route("/reset", methods=['POST'])
def reset():
    if request.method == 'POST':
        try:
            subprocess.run('rm -rf /tmp/uploads/*;, shell=True')
            subprocess.run('rm -rf /tmp/processed/*;, shell=True')
        except Exception as e:
            print('error was ' + str(e))
            return redirect('/')
    flash('staging reset')
    return redirect('/')


if __name__ == "__main__":
    producer = kafka.KafkaProducer(bootstrap_servers='my-cluster-kafka-bootstrap:9092')
    app.run(host='0.0.0.0')
