# Use Python 3.11 slim image
FROM python:3.11-slim

# Install system dependencies including X11 and Xvfb
RUN apt-get update && apt-get install -y \
    xvfb \
    x11-utils \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements first to leverage Docker cache
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Download OmniParser weights
RUN apt-get update && apt-get install -y git && \
    git clone https://github.com/microsoft/OmniParser.git && \
    pip install -r OmniParser/requirements.txt && \
    pip install huggingface-cli && \
    huggingface-cli download microsoft/OmniParser --local-dir OmniParser/weights/ && \
    apt-get remove -y git && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Set up virtual display
ENV DISPLAY=:99

# Start Xvfb and the FastAPI server
CMD Xvfb :99 -screen 0 1024x768x16 & uvicorn core_server.server:app --host 0.0.0.0 --port 8080
