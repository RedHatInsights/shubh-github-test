# Start from the official Go image
FROM golang:1.23.4-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy go mod and sum files
COPY go.mod ./

# Download all dependencies
RUN go mod download

# Copy the source code into the container
COPY . .

# Build the application
RUN go build -o main .

# Expose port 8080 (adjust if your app uses a different port)
EXPOSE 8080

# Run the application
CMD ["./main"]
