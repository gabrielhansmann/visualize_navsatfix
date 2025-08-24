#!/usr/bin/env bash
# Usage:
#   ./docker.sh [BAG_PATH_UNDER_REPO] [TOPIC] [CONTAINER_NAME]
# Examples:
#   ./docker.sh bag_files/2025-08-06-metternich_eule_0.mcap /lynx/gps/fix
#   ./docker.sh bag_files/2025-08-06-metternich_eule_dir /vehicle/gps/fix my-container
#
# Result: CSV written to ./output/ on the host.

set -euo pipefail

IMG="navsatfix-jazzy:latest"
BAG_PATH="${1:-}"
TOPIC="${2:-}"
CONTAINER_NAME="${3:-ros-jazzy-gps}"

# --- preflight checks -------------------------------------------------------
if ! command -v docker >/dev/null 2>&1; then
  echo "Error: docker not found in PATH." >&2
  exit 1
fi
if [[ -z "${BAG_PATH}" || -z "${TOPIC}" ]]; then
  echo "Usage: $0 [BAG_PATH_UNDER_REPO] [TOPIC] [CONTAINER_NAME]" >&2
  exit 2
fi
if [[ "${BAG_PATH}" = /* ]]; then
  echo "Error: please pass BAG_PATH relative to the repo (not absolute)." >&2
  exit 3
fi
if [[ ! -e "${BAG_PATH}" ]]; then
  echo "Error: BAG path does not exist in repo: ${BAG_PATH}" >&2
  exit 4
fi

REPO_DIR="$(pwd)"
OUTPUT_DIR="${REPO_DIR}/output"
mkdir -p "${OUTPUT_DIR}"

# --- build image if missing -------------------------------------------------
if docker image inspect "${IMG}" >/dev/null 2>&1; then
  echo "Using existing image: ${IMG}"
else
  echo "Building ${IMG} from Dockerfile..."
  docker build -t "${IMG}" -f Dockerfile .
fi

# --- run exporter inside container ------------------------------------------
echo "Running export..."
echo "  Bag path   : ${BAG_PATH}"
echo "  Topic      : ${TOPIC}"
echo "  Container  : ${CONTAINER_NAME}"
echo "  Output dir : ${OUTPUT_DIR}"

docker run --rm \
  --name "${CONTAINER_NAME}" \
  -v "${REPO_DIR}":/home/ubuntu/ros2_ws \
  "${IMG}" \
  -lc "
    set -e
    cd /home/ubuntu/ros2_ws/output
    python3 /home/ubuntu/ros2_ws/export_gps.py \"/home/ubuntu/ros2_ws/${BAG_PATH}\" \"${TOPIC}\"
  "