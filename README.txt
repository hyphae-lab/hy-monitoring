### This monitoring script has two aspects: ###
#     - single resource monitor check (running on the same machine as whatever resource)
#     - monitor of all monitors (running on ONE central machine)

### INSTALL General Instructions (see below for specifics on Single vs All) ###
# update the apt stuff
sudo apt update

# instal utils
sudo apt install unzip
sudo apt install git

# Get repo
git clone https://github.com/hyphae-lab/hy-monitoring.git

# First install
cd hy-monitoring/
pwd # print the current working directory and copy the path
# 'source include' aliases (when prompted paste the working directory path)
. aliases.sh

# now you have all the hyphae-monitor-* commands/aliases
hyphae-monitor-help # will get you all the commands you need to know about, like status, start, stop

# Python/PIP
sudo apt install python3-pip


### FOR MONITOR-ALL ###
 see "AWS Simple Email Service (SES)" below


### FOR MONITOR-ALL ###




### INSTALL AWS SIMPLE EMAIL SERVICE
# https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
cd # back to home dir
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
rm awscliv2.zip
sudo ./aws/install
# configure AWS CLI: create two files under $HOME/.aws
mkdir $HOME/.aws
# 1. config in $HOME/.aws
vi $HOME/.aws/config
# [default]
#  region = us-west-2  # or whatever region you are in
#  output = json
vi $HOME/.aws/credentials
# get the IAM role access key/secret from https://us-east-1.console.aws.amazon.com/iamv2/home?region=us-west-2
# create a user
# assign a policy (in-line acceptable if no appropriate existing policy)
# policy should contain this resulting JSON
#  when editing policy visually, make sure to enable the "SendEmail" action in the "write" section
# "Statement": [
#  		{
#  			"Sid": "VisualEditor0",
#  			"Effect": "Allow",
#  			"Action": "ses:SendEmail",
#  			"Resource": [
#  				"arn:aws:ses:*:<accountIdProvidedForYou>:identity/*",
#  				"arn:aws:ses:*:<accountIdProvidedForYou>:configuration-set/*"
#  			]
#  		}
#  	]
# go back to user and copy the access key and secret (possibly create a second access key)
#  maybe save the access key secret to 1password just in case
# copy paste
# [default]
#  aws_access_key_id = asdasdasd
#  aws_secret_access_key = adsasdasd

