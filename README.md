# Docker Images for Python 3.x pre-releaes on CircleCI

CircleCI doesn't make official `cimg/python` images available for Python pre-releases, so this does. The goal is to make it straightforward to test projects on the beta or release candidate versions of upcoming major Python releases. Available Python versions:

- 3.12.0:
    - 3.12.0rc3
    - 3.12.0 (production release)
- 3.13.0:
    - (No 3.13.0a1 release)
    - 3.13.0a2
    - 3.13.0a3
    - (No 3.13.0a4 release; Pyenv never supported it)
    - 3.13.0a5

This is pretty much a copy of the official CircleCI image with some small tweaks. CircleCI's source can be found at: https://github.com/CircleCI-Public/cimg-python/


## Usage

Use these images just like you'd normally use a `cimg/python:<version>` image. For example, from a CircleCI config file like:

```yaml
version: 2.1

jobs:
  test:
    docker:
      - image: mr0grog/circle-python-pre:3.13.0a5
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
