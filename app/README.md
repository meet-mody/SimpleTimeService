# Flask Timestamp & IP API

This is a simple web application built with Python and Flask that provides an API endpoint to return the current server timestamp and the IP address of the client making the request.

The application is containerized using Docker.

## Features

* Provides a single API endpoint `/`.
* Returns the current timestamp in ISO format (with UTC indicated).
* Returns the public IP address of the requester.
* Responds in JSON format.
* Runs as a non-root user inside the Docker container for better security.

## Prerequisites

* Docker installed on your system.

## Building the Docker Image

1.  **Clone the repository (if you haven't already):**
    ```bash
    git clone https://github.com/meet-mody/SimpleTimeService.git
    cd SimpleTimeService/app/
    ```

2.  **Ensure you have the following files:**
    * `main.py` (the Flask application code)
    * `Dockerfile`
    * `requirements.txt` (containing at least `Flask`)

3.  **Build the Docker image:**
    ```bash
    docker build -t time-service:latest .
    ```
    *(You can replace `time-service` with your preferred image name)*

## Running the Application

1.  **Run the Docker container:**
    ```bash
    docker run -p 8080:8080 -d --name time-service-app time-service:latest
    ```
    * `-p 8080:8080`: Maps port 8080 on your host machine to port 8080 inside the container. If your 8080 is already in use, try `-p {DIFF_PORT}:8080`
    * `-d`: Runs the container in detached mode (in the background).
    * `--name time-service-app`: Assigns a convenient name to the container.
    * `time-service:latest`: The name of the image you built with `latest` tag

## Usage

Once the container is running, you can access the API endpoint:

* **Using `curl` (from your terminal):**
    ```bash
    curl http://localhost:8080/
    ```
    *(Replace `8080` if you used a different host port mapping)*

* **Using a web browser:**
    Navigate to `http://localhost:8080/` *(Again, adjust the port if necessary)*

### Example Response

You will receive a JSON response similar to this:

```json
{
  "timestamp": "2025-04-23T23:22:48.123456 UTC",
  "ip": "YOUR_IP_ADDRESS"
}