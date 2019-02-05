Adds tasks to simplify using Python in Visual Studio Team Services build definitions.

Note that these tasks only work on Windows build agents. For non-Windows platforms, add the *Use Python Version* task to select the version you need and configure your command `PATH`.

# Install Python

The *Install Python* task will install Python using a package from [nuget.org](https://nuget.org) and add it to `PATH`. These packages are part of the official release of CPython.

Most other tasks assume you have already run this task to install the desired runtime. The folder where they are installed is customizable, but be aware that you may need to update subsequent task configuration if you change this.

The recommended configuration for using this task with multiple versions of Python is to enable multi-configuration on the phase and specify the version number as a Multiplier. See [the documentation](https://go.microsoft.com/fwlink/?linkid=835763) for information about parallel execution.

(Note that the first-party *Use Python Version* task is preferable on the Hosted queues and works on all platforms, though as of 02 May 2018 is not fully available.)

# Run Python command

The *Run Python command* task will let you enter any script or command to run with Python.

Consider using the *Python Script* task for inline code.

# Run Python tests

The *Run Python tests* task will install and use [PyTest](https://pytest.org) to run your test suite. The [pytest-azurepipelines](https://pypi.org/project/pytest-azurepipelines) plugin is used to publish results. If you enable code coverage, you will need to add a "Publish Code Coverage Results" task referencing `coverage.xml` (Cobertura format) and `htmlcov` from this task's working directory.

# Build Python wheels with pip

The *Build Python wheels with pip* task uses the `pip wheel` command to compile wheels. This may be passed either the source directory to build, or the names and versions of packages that have already been published on the [Python Package Index](https://pypi.org). It will ensure that `pip`, `wheel`, `setuptools` and `cython` are installed before running.

As the Python packaging ecosystem moves forward, the `pip wheel` command is likely to be more reliable than using `setup.py`.

# Build Python wheels

The *Build Python wheels* task uses a `setup.py` file to compile wheels. It will ensure that `pip`, `wheel`, `setuptools` and `cython` are installed before running.

# Build Python sdist

The *Build Python sdist* task uses a `setup.py` file to produce a source distribution. It will ensure that `setuptools` and `cython` are installed before running.

# Upload Python package

The *Upload Python package* task uses `twine` to upload your built packages to the [Python Package Index](https://pypi.org). You may also select to upload to the test instance.

Your username and password are required. It is recommended to add these as [encrypted build variables](https://docs.microsoft.com/en-us/vsts/build-release/concepts/definitions/build/variables?view=vsts&tabs=batch#secret-variables) or a [secured configuration file](https://docs.microsoft.com/en-us/vsts/build-release/tasks/utility/download-secure-file?view=vsts) rather than adding them directly to the task.

# Update version variables

The *Update version variables* task will search Python files for a `__version__` variable and replace its value with the version of your build. By running this before publishing, you can automatically update the version number and ensure your upload succeeds.

# Create Conda Environment

The experimental *Create Conda Environment* task will create an environment and install packages using [conda](https://conda.io).

You must provide a list of packages to install that includes Python itself, for example: `python=3.6 numpy jupyter`.

# Run Jupyter Notebook

The experimental *Run Jupyter Notebook* task will use Jupyter to execute an `.ipynb` file and store the output as HTML.

For best results, it is recommended to create a conda environment that includes at least `nbconvert` and whatever kernels your notebooks require (for example, `ipykernel` for Python).


