# Use Python 3.6 slim image as the base
FROM python:3.6-slim

# Set the working directory inside the container
WORKDIR /app

# Create and activate a virtual environment
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy the requirements.txt file and install the dependencies
COPY requirements.txt ${WORKDIR}
RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 8000

# Copy the project files into the container
COPY . ${WORKDIR}

# Make entrypoint.sh executable
RUN chmod +x entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["sh", "entrypoint.sh"]
