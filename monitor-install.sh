sudo apt update
sudo apt install unzip

sudo apt install git
git clone https://github.com/hyphae-lab/hy-monitoring.git

sudo apt install python3-pip

# install and enable aliases (if it does not interfere with other aliases alaready in place)
# NOTE: hy-monitoring directory matches the git clone repository name
cp hy-monitoring/aliases.sh $HOME/.bash_aliases
. $HOME/.bash_aliases