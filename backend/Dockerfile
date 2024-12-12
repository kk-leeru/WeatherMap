<<<<<<< HEAD
#Run from root flutter_application_1 dir, exec 'docker build -f backend/Dockerfile -t weather-region .'

# Use the official Python image from the Docker Hub
FROM python:3.9-slim

# Set the working directory for any following commands below
WORKDIR /app

# Copy the requirements file into the container
COPY /backend/requirements.txt .
=======
# Use the official Python image from the Docker Hub
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file into the container
COPY requirements.txt .
>>>>>>> 3a7cfcbd3123eee81dbf43c84e859265b748199a

# Install the dependencies
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of your application code into the container
<<<<<<< HEAD
#. means copy into curr dir which is /app
COPY ./backend/crawl.py /app/crawl.py
COPY .env /app/.env 

=======
COPY crawl.py .
>>>>>>> 3a7cfcbd3123eee81dbf43c84e859265b748199a

# Command to run the application
CMD ["gunicorn", "-b", ":8080", "crawl:app"]
