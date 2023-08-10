import http.server
import socketserver
import subprocess
import os
import json

# this will insert the .ini or .env key=value lines into a dictionary
#   if a "key" repeats more than once it will become an array of all key=value values
def get_env():
    env = {}
    if os.path.isfile('monitor.ini'):
        file = open('monitor.ini', 'r')
        for line in file:
            if not '=' in line:
                continue
            (key, value) = line.replace('\n', '').split('=')
            key = key.strip()
            value = value.strip()
            if key in env:
                if type(env[key]) == list:
                    env[key].append(value)
                else:
                    env[key] = [env[key], value]
            else:
                env[key] = value
    return env
env = get_env()

class MyHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path.startswith('/check?'):
            (path, query) = self.path.split('?')
            if not query or  not 'secret='+env['secret'] in query:
                self.bad_secret_code()
            else:
                self.execute_code()
        else:
            self.blank_response()

    def blank_response(self):
        self.send_response(404)
        self.send_header('Content-type', 'text/plain')
        self.end_headers()
        self.wfile.write('404'.encode('utf-8'))

    def bad_secret_code(self):
        self.send_response(401)
        self.send_header('Content-type', 'text/plain')
        self.end_headers()
        self.wfile.write('401'.encode('utf-8'))

    def execute_code(self):

        env = get_env()
        output = ''
        checks = {}

        # Get all "cmd" properties from ENV
        #   if "cmd" appeared more than 1, then it is an array;
        #   treat it like an array
        cmds = env['cmd'] if type(env['cmd']==list) else [env['cmd']]
        for i, cmd in enumerate(cmds):
            cmd_without_new_line = cmd + " | tr -d '\\n' "
            cmd_process = subprocess.run(cmd_without_new_line, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            checks[env['cmd_label'][i]] = cmd_process.stdout == env['cmd_expected_ouput'][i]

        self.send_response(200)
        self.send_header('Content-type', 'text/plain')
        self.end_headers()
        self.wfile.write(json.dumps(checks).encode('utf-8'))

PORT = int(env['port'])

with socketserver.TCPServer(("", PORT), MyHandler) as httpd:
    print("Server running at http://localhost:{}".format(PORT))
    httpd.serve_forever()
