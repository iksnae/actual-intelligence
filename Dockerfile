FROM ubuntu:24.04

LABEL maintainer="iksnae/actual-intelligence"
LABEL description="Docker image for building the Actual Intelligence book"

# Prevent apt from prompting for input
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && apt-get install -y \
    nodejs \
    npm \
    pandoc \
    texlive-xetex \
    texlive-fonts-recommended \
    texlive-plain-generic \
    texlive-lang-english \
    texlive-latex-extra \
    calibre \
    rsync \
    curl \
    git \
    make \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set up work directory
WORKDIR /app

# Create entrypoint script
RUN echo '#!/bin/bash\nexec "$@"' > /entrypoint.sh \
    && chmod +x /entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]
