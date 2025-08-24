# Visualizing `sensor_msgs/NavSatFix` in ROS 2 Jazzy with QGIS

This guide shows how to convert ROS 2 `NavSatFix` messages from a bag file into CSV
and visualize them in **QGIS** with OSM basemap.

It is designed to be **simple and reproducible** inside a Docker container.

## Requirements
- [Docker](https://docs.docker.com/desktop/) (tested with [osrf/ros:jazzy-desktop-full](https://hub.docker.com/r/osrf/ros))
- A ros2 bag file containing `sensor_msgs/msg/NavSatFix`

## Usage
1. Clone this repository:
```bash
git clone !!!
```
2. Run the `docker.sh` script with your specific paths:
```bash
sudo bash docker.sh [BAG_PATH] [TOPIC] [CONTAINER_NAME]
```
- `BAG_PATH`: path to the bag dir
- `TOPIC`: topic inside the bag dir with type `sensor_msgs/msg/NavSatFix`
- `CONTAINER`: [optional] container name

## Visualize with QGis:
1. Install QGis:
```bash
sudo apt update
sudo apt install qgis qgis-plugin-grass
```
2. Open qgis:
```bash
qgis
```
3. In qgis go to:
- Layer -> Add Layer -> Add Delimited Text Layer
- File name is the generated csv file in `./output`.
- Encoding: UTF-8
- File Format: CSV (comma seperated values)
- Geometry definition: X=latitude, Y=longitude, Geometry CRS: Project CRS: EPSG:4326 - WGS 84
- Add the Layer

4. For a map underneath in qgis:
- Plugins -> Manage and Install Plugins
- Install Plugin QuickMapServices
- Web -> QuickMapServices -> OSM -> OSM Standard

5. To generate a path through the points:
- Processing -> Toolbox
- Vector creation -> Points to path
