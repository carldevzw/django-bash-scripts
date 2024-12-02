#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if Python is installed
echo "Checking if Python is installed..."
if ! command_exists python3; then
    echo "Python3 is not installed. Installing Python3..."
    if command_exists apt; then
        sudo apt update
        sudo apt install -y python3 python3-pip
    elif command_exists yum; then
        sudo yum install -y python3 python3-pip
    elif command_exists brew; then
        brew install python
    else
        echo "Package manager not found. Please install Python manually."
        exit 1
    fi
else
    echo "Python3 is installed."
fi

# Check if python3-venv is installed
if ! python3 -m venv --help >/dev/null 2>&1; then
    echo "The 'python3-venv' package is missing. Installing it..."
    if command_exists apt; then
        sudo apt update
        sudo apt install -y python3-venv
    elif command_exists yum; then
        sudo yum install -y python3-venv
    else
        echo "Could not install 'python3-venv'. Please install it manually."
        exit 1
    fi
else
    echo "'python3-venv' is installed."
fi

# Prompt the user for the project and app names
read -p "Enter the name of your Django project: " PROJECT_NAME
read -p "Enter the name of your authentication app: " APP_NAME

# Create a virtual environment
echo "Creating a virtual environment..."
if [ -d "venv" ]; then
    echo "Virtual environment already exists. Skipping creation."
else
    python3 -m venv venv
    if [ $? -ne 0 ]; then
        echo "Failed to create the virtual environment. Please ensure 'python3-venv' is installed."
        exit 1
    fi
    echo "Virtual environment created."
fi

# Activate the virtual environment
source venv/bin/activate

# Install Django in the virtual environment
echo "Installing Django..."
pip install --upgrade pip
pip install django

# Create a new Django project
if [ ! -d "$PROJECT_NAME" ]; then
    echo "Creating a new Django project: $PROJECT_NAME..."
    django-admin startproject "$PROJECT_NAME"
    echo "Django project created."
else
    echo "Django project already exists. Skipping creation."
fi

# Navigate to the Django project directory
cd "$PROJECT_NAME" || exit

# Create a new Django app for authentication
if [ ! -d "$APP_NAME" ]; then
    echo "Creating a new Django app: $APP_NAME..."
    python manage.py startapp "$APP_NAME"
    echo "Django app created."
else
    echo "Django app already exists. Skipping creation."
fi

echo "Setup complete! Your Django project '$PROJECT_NAME' and app '$APP_NAME' are ready."

# Optional: Keep the virtual environment active
echo "To activate your virtual environment in the future, use: source venv/bin/activate"
