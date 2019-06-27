#Install python-virtualenv, a Python virtual environment
sudo apt install python-virtualenv

#Install python-pip, a package manager for Python packages
sudo apt install python-pip

#Create a directory for the project
mkdir flask_project

#Create a virtual environment for the project -venv
cd flask_project
virtualenv venv

#Activate the virtual environment
. venv/bin/activate

#Install Flask
pip install flask

#Copy Python app(from other place) to flask_project directory
copy ...../original.py newapp.py

#Run the Python application
python newapp.py

#Deactive the virtual enviornment
deactivate


#Others
#to check used ports
sudo netstat -plunt

