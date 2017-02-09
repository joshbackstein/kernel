# Set image file name
IMAGEFILE="os.iso"

./scripts/build.sh "$IMAGEFILE"
./scripts/run.sh "./image/$IMAGEFILE"
