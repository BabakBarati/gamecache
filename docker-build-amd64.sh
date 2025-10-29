docker build -f Dockerfile --platform linux/amd64 -t gamecache:latest-amd64 .
rm -f gamecache-latest-amd64.tar gamecache-amd64.tar
docker save -o gamecache-latest-amd64.tar gamecache:latest-amd64
  