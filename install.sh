sudo apt update
sudo apt install unzip

# https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
rm awscliv2.zip
sudo ./aws/install

sudo apt install git
git clone https://github.com/hyphae-lab/hy-monitoring.git

sudo apt install python3-pip

# install and enable aliases
cp hy-monitoring/aliases.sh $HOME/.bash_aliases
. $HOME/.bash_aliases