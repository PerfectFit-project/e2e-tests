bash fetch_and_build_all_images.sh
docker-compose up

#TODO: Make this start when all containers fully up and healthy
sleep 30
behave
