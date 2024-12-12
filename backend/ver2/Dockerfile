#Run from root flutter_application_1 dir, exec 'docker build -f backend/Dockerfile -t weather-region .'

# Use the official Python image from the Docker Hub
# FROM python:3.9-slim
FROM tiangolo/uvicorn-gunicorn-fastapi:python3.8


# Set the working directory for any following commands below
WORKDIR /code

# Copy the requirements file into the container
COPY /backend/ver2/requirements.txt /code/requirements.txt

# Install the dependencies
# RUN pip install --upgrade pip
RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt

# Copy the rest of your application code into the container
#. means copy into curr dir which is /app
# COPY ./backend/fastAPI/restAPI.py /code/restAPI.py
#COPY dir app 
COPY ./backend/ver2/app /code/app
# COPY .env /code/.env 


# Command to run the application
CMD ["fastapi", "run", "app/restAPI.py", "--port", "80"]
