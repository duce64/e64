# Dockerfile

# Flutter SDK base image
FROM cirrusci/flutter:stable

# Set working directory
WORKDIR /app

# Copy all files
COPY . .

# Run build
RUN flutter build web

# Use simple web server (e.g. python http.server)
EXPOSE 80
CMD ["python3", "-m", "http.server", "80", "--directory", "build/web"]
