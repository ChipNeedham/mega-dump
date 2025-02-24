# Mega Dump 💩
##### _prod => dev mysql dump and sync utility_

## Features
- Runs **MySQL 8** in Docker with **persistent storage**.
- Includes **phpMyAdmin** for easy database management.
- Periodically syncs data from **AWS Aurora** (overwrites dev changes).
- Supports excluding certain tables from data transfer.

## Prerequisites
- Docker Desktop (latest)

## Setup Instructions

### 1. Create a .env file
- duplicate .env.example and fill required fields
- or source a .env file from a teammate

### 2. Build the docker container
```shell
docker-compose up -d
```
### 3. Run the sync script
```shell
bash scripts/sync_prod_to_dev.sh
```
### 4. Wait
![bean man](mr-bean-waiting.gif)
### 5. Connect and Manage
- db host will be localhost:**3366** by default
- not a typo, 3366
- phpmyadmin can be accessed at localhost:8888