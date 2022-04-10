from flask import Flask, render_template

app = Flask(__name__)

@app.route('/')
def hello():
    return render_template('hello.html')

@app.route('/<link>')
def video(link):
    return render_template('video.html', link=link)

application = app

if __name__ == '__main__':\
    app.run()
    # app.run(debug = True)
    # app.run(host= '42.42.42.42', port=1984, debug=False)
