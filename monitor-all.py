import http.server
import socketserver
import subprocess
import os
import sys
import json
import re
import time


# this will insert the .ini or .env key=value lines into a dictionary
#   if a "key" repeats more than once it will become an array of all key=value values
def get_env():
    env = {}
    if os.path.isfile('monitor-all.ini'):
        file = open('monitor-all.ini', 'r')
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

def check_wget_log_for_errors(log_string_):
    log_string = log_string_.lower().replace('http/1.0', 'http/x.x').replace('http/1.1', 'http/x.x').replace('http/1.2', 'http/x.x')

    if 'http/1.0 200 ok' in log_string:
        return False

    # 4xx or 5xx errors
    if 'http/x.x 401' in log_string:
        return 'unauthorized_error'
    if 'http/x.x 404' in log_string:
        return 'not_found_error'
    if 'http/x.x 4' in log_string:
        return '4xx_error'
    if 'http/x.x 5' in log_string:
        return 'server_error'

    if 'connection refused' in log_string:
        return 'connection_error'

    return 'other_error'

def check_wget_response_for_errors(json_object):
    if type(json_object) == dict:
        has_failed_checks = False
        for k in json_object:
            # if a check has value "false", then it's an error
            # else if might be TRUE or an actual string/numeric value
            if json_object[k] == False:
                has_failed_checks = True
                break
        if has_failed_checks:
            return 'has_failed_checks'
        else
            return False

    return 'content_error'

def test_send_alert(to_email, subject, body):
    print ('testing send alert', to_email, subject, body)

def send_alert(to_email, subject, body):
    if os.environ.get('Z_TEST_DEBUG') is not None:
        test_send_alert(to_email, subject, body)
        return
    body_file_name = 'alert-email-body.json'
    body_file = open(body_file_name)
    body_string = body_file.read()
    body_string = body_string.replace('__subject__', subject)

    strip_tags_regexp = re.compile('</?[^>]+>')
    body_string = body_string.replace('__text__', strip_tags_regexp.sub(' ', body)
    body_string = body_string.replace('__html__', body)

    body_file_tmp = open(body_file_name+'.tmp', 'w')
    body_file_tmp.write(body_string)
    body_file_tmp.close()

    # AWS SES send email command:
    # https://docs.aws.amazon.com/cli/latest/reference/ses/send-email.html
    # https://us-west-2.console.aws.amazon.com/ses/home
    aws_email_cmd = 'aws ses send-email --from "%s" --destination "ToAddresses=%s" --message file://%s 2>&1)' % (env['from_email'], to_email, body_file_name+'.tmp')

env = get_env()

# Get all "url" properties from ENV
#   if "url" appeared more than 1, then it is an array;
#   treat it like an array
urls = env['url'] if type(env['url']==list) else [env['url']]
url_secrets = env['url_secret'] if type(env['url_secret']==list) else [env['url_secret']]
url_names = env['url_name'] if type(env['url_name']==list) else [env['url_name']]
url_ids = env['url_id'] if type(env['url_id']==list) else [env['url_id']]
alert_emails = env['alert_email'] if type(env['alert_email']==list) else [env['alert_email']]

downloads_dir='monitor-all-downloads'
# loop on all URLs to monitor
for i, url_id in enumerate(url_ids):
    # new + old log file
    log_file_name = url_ids[i]+'.log'
    new_log_file_name = url_ids[i]+'.new.log'

    # new + old json/ouput file
    output_json_file_name = url_ids[i]+'.json'
    new_output_json_file_name = url_ids[i]+'.new.json'

    # -S show server headers, -o debug/stderr to log file, -O save output to file
    wget_cmd = "wget -S -o %s -O %s %s " % (new_log_file_name, new_output_json_file_name, urls[i])

    cmd_process = subprocess.run(cmd_without_new_line, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

    if cmd_process.stderr != "":
        # error in executing WGET itself! ouch!
        log_file = open(log_file_name, 'w')
        log_file.write(' wget fetch failed: please inspect the code or the server python modules')
        log_file.close()

        send_alert(alert_emails[i], url_names[i]+': wget fetch failed', 'please inspect the code or the server python modules')
    else:
        log_file = open(log_file_name)
        log_error = check_wget_log_for_errors(log_file.read())
        log_file.close()

        new_log_file = open(new_log_file_name)
        new_log_error = check_wget_log_for_errors(new_log_file.read())

        output_json_file = open(output_json_file_name)
        output = json.load(output_json_file)
        output_json_file.close()
        output_error = check_wget_response_for_errors(output)

        new_output_json_file = open(new_output_json_file_name)
        new_output = json.load(new_output_json_file)
        new_output_error = check_wget_response_for_errors(new_output)

        alert_body = ''
        alert_subject = url_names[i]
        if not log_error and not new_log_error:
            # no error, no change, do nothing

        elif log_error and new_log_error:
            if log_error != new_log_error
                # alert of error change
                alert_subject += ': has a new error'
            else
                # no change
                # maybe alert for some times of the error (if STILL in error state)
                alert_subject += ': still has error'

        elif log_error or new_log_error:
            # alert about changes
            alert_subject += ': has an error'
            alert_subject += ': error is fixed'


        elif not output_error and not new_output_error:
            # no error, no change, do nothing
        elif output_error and new_output_error:
            if output_error != new_output_error
                # alert of error change
                alert_subject += ': has new error'
            else
                # no change
                # maybe alert for some times of the error (if STILL in error state)
                alert_subject += ': still has error'

        elif output_error or new_output_error:
            # alert about changes
            alert_subject += ': has an error'
            alert_subject += ': error is fixed'

        elif output != new_output:
            # alert about changes
            alert_subject += ': changes have occurred'

        if alert_body:
            send_alert(alert_emails[i], alert_subject, alert_body)

        # save new to old before end of check
        log_file = open(new_log_file_name, 'w')
        log_file.write(new_log_file.read())
        log_file.close()

        output_json_file = open(output_json_file_name, 'w')
        output_json_file.write(new_output_json_file.read())
        output_json_file.close()

    time.sleep(.5)




