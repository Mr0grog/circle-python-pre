# Docker Images for Python 3.x pre-releaes on CircleCI

CircleCI doesn't make official `cimg/python` images available for Python pre-releases, so this does. The goal is to make it straightforward to test projects on the beta or release candidate versions of upcoming major Python releases. Available Python versions (versions suffixed with `t` are [“free-threading,” or no GIL](https://py-free-threading.github.io), a new feature in 3.13.0+):

- 3.12.0:
    - 3.12.0rc3
    - 3.12.0 (production release)
- 3.13.0:
    - (No 3.13.0a1 release)
    - 3.13.0a2
    - 3.13.0a3
    - (No 3.13.0a4 release; Pyenv never supported it)
    - 3.13.0a5
    - 3.13.0a6
    - 3.13.0b1
    - 3.13.0b2
    - 3.13.0b3
    - 3.13.0b4, 3.13.0b4t (The `t` image does not have Poetry.)
    - 3.13.0rc1, 3.13.0rc1t (The `t` image does not have Poetry.)
    - 3.13.0rc2, 3.13.0rc2t (The `t` image does not have Poetry.)
    - 3.13.0rc3, 3.13.0rc3t (The `t` image does not have Poetry.)
    - 3.13.0, 3.13.0t (production release) (The `t` image does not have Poetry.)
- 3.14.0:
    - 3.14.0a1, 3.14.0a1t (The `t` image does not have Poetry.)
    - 3.14.0a2, 3.14.0a2t (The `t` image does not have Poetry.)
    - 3.14.0a3, 3.14.0a3t (The `t` image does not have Poetry.)
    - 3.14.0a4, 3.14.0a4t (The `t` image does not have Poetry.)
    - 3.14.0a5, 3.14.0a5t (The `t` image does not have Poetry.)
    - 3.14.0a6, 3.14.0a6t (The `t` image does not have Poetry.)

This is pretty much a copy of the official CircleCI image with some small tweaks. CircleCI's source can be found at: https://github.com/CircleCI-Public/cimg-python/

⚠️ Please note that, in some images, `poetry` may be missing. It has several binary dependencies that are sometimes not yet compatible with pre-release versions of Python or are not yet compatible with free-threaded Python.


## Usage

Use these images just like you'd normally use a `cimg/python:<version>` image. For example, from a CircleCI config file like:

```yaml
version: 2.1

jobs:
  test:
    docker:
      - image: mr0grog/circle-python-pre:3.14.0a6
    steps:
      - checkout
      - run:
          name: Install Dependencies
          command: |
            pip install .

      - run:
          name: Tests
          command: |
            pytest -vv

workflows:
  ci:
    jobs:
      - test
```


## License & Copyright

Copyright (C) 2023-2024 Rob Brackett. See the [`LICENSE`](./LICENSE) file for details.

Most of the Dockerfile is a fork of CircleCI's official image, which is also MIT-licensed: https://github.com/CircleCI-Public/cimg-python/
