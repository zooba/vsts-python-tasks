Adds tasks to simplify using Python in Visual Studio Team Services build definitions.

# Install Python

The *Install Python* task will install one or more copies of Python using packages from [nuget.org](https://nuget.org). These packages are part of the official release of CPython.

Most other tasks assume you have already run this task to install the desired runtimes. The folder where they are installed is customizable, but be aware that you will need to update subsequent task configuration if you change this.

# Run Python tests

The *Run Python tests* task will install and use [PyTest](https://pytest.org) to run your test suite. You should add a "Publish Test Results" task after this in order to see your test status in the build results page.

# Build Python wheels with pip

The *Build Python wheels with pip* task uses the `pip wheel` command to compile wheels. This may be passed either the source directory to build, or the names and versions of packages that have already been published on the [Python Package Index](https://pypi.org). It will ensure that `pip`, `wheel`, `setuptools` and `cython` are installed before running.

As the Python packaging ecosystem moves forward, the `pip wheel` command is likely to be more reliable than using `setup.py`.

# Build Python wheels

The *Build Python wheels* task uses a `setup.py` file to compile wheels. It will ensure that `pip`, `wheel`, `setuptools` and `cython` are installed before running.

# Build Python sdist

The *Build Python sdist* task uses a `setup.py` file to produce a source distribution. It will ensure that `setuptools` and `cython` are installed before running.

# Upload Python package

The *Upload Python package* task uses `twine` to upload your built packages to the [Python Package Index](https://pypi.org). You may also select to upload to the test instance.

Your username and password are required. It is recommended to add these as encrypted build variables rather than adding them directly to the task.

# Update version variables

The *Update version variables* task will search Python files for a `__version__` variable and replace its value with the version of your build. By running this before publishing, you can automatically update the version number and ensure your upload succeeds.
