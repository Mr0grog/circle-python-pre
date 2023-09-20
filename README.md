# Docker Images for Python 3.12 pre-releaes on CircleCI

CircleCI doesn't make official `cimg/python` images available for Python pre-releases, so this does. The goal is to make it straightforward to test projects on the beta or release candidate versions of upcoming major Python releases.

This is pretty much a copy of the official CircleCI image with some small tweaks. CircleCI's source can be found at: https://github.com/CircleCI-Public/cimg-python/


## License & Copyright

Copyright (C) 2023 Rob Brackett. See the [`LICENSE`](./LICENSE) file for details.

Most of the Dockerfile is a fork of CircleCI's official image, which is also MIT-licensed: https://github.com/CircleCI-Public/cimg-python/
