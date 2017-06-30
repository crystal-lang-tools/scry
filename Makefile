darwin:
	/bin/bash -c "mkdir -p bin/darwin"
	/bin/bash -c "crystal build src/scry.cr --release --no-debug -o bin/darwin/scry"

linux:
	/bin/bash -c "mkdir -p bin/linux"
	/bin/bash -c "crystal build src/scry.cr --release --no-debug -o bin/linux/scry"