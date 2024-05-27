# Use an official Ubuntu as a parent image
FROM ubuntu:20.04

# Set environment variables to non-interactive to avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# # Update the package list and install necessary packages
# RUN apt-get update && \
#     apt-get install -y openjdk-17-jre wget && \
#     apt-get clean

# Update the package list and install necessary packages
RUN apt-get update && \
    apt-get install -y openjdk-17-jre wget curl jq && \
    apt-get clean

# Set the working directory in the container
WORKDIR /minecraft

# Download the Minecraft server jar file
# RUN wget -O server.jar https://launcher.mojang.com/v1/objects/a2f9e74b3a1e68d59fb3d5f344ed5f68b3d255a7/server.jar

# Fetch the latest Minecraft server JAR URL using Mojang's API
RUN LATEST_URL=$(curl -s https://launchermeta.mojang.com/mc/game/version_manifest.json | jq -r '.latest.release') && \
    JAR_URL=$(curl -s https://launchermeta.mojang.com/mc/game/version_manifest.json | jq -r --arg VERSION "$LATEST_URL" '.versions[] | select(.id == $VERSION) | .url') && \
    SERVER_URL=$(curl -s $JAR_URL | jq -r '.downloads.server.url') && \
    wget -O server.jar $SERVER_URL

# Accept the EULA by creating the eula.txt file with the required content
RUN echo "eula=true" > eula.txt

# Expose the necessary port
EXPOSE 25565

# Run the Minecraft server
CMD ["java", "-Xmx1024M", "-Xms1024M", "-jar", "server.jar", "nogui"]
