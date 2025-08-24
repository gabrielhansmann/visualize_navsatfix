FROM osrf/ros:jazzy-desktop-full

ENV DEBIAN_FRONTEND=noninteractive

# System packages
RUN apt-get update && apt-get install -y --no-install-recommends \
      python3-venv python3-pip ca-certificates tzdata \
    && rm -rf /var/lib/apt/lists/*

# Python venv with rosbags
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv "$VIRTUAL_ENV" \
 && . "$VIRTUAL_ENV/bin/activate" \
 && pip install --upgrade pip \
 && pip install rosbags pandas

ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Workdir mirrors your repo via bind mount
WORKDIR /home/ubuntu/ros2_ws

ENTRYPOINT ["/bin/bash"]
