# Use an official Python runtime as a parent image
FROM python:3.11-slim

# Set a working directory for the application inside the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install the required dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Create a non-root user to run the application
RUN useradd -m simpleuser

# Change the ownership of the /app directory to the non-root user
RUN chown -R simpleuser:simpleuser /app

# Switch to the non-root user
USER simpleuser

# Define the command to run the application
CMD ["python", "main.py"]