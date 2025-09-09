from setuptools import setup, find_packages

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

with open("requirements.txt", "r", encoding="utf-8") as fh:
    requirements = fh.read().splitlines()

setup(
    name="nss-gui",
    version="1.0.0",
    author="madroots",
    author_email="example@example.com",
    description="A native Linux GUI application for scanning network services",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/madroots/Network-Service-Scanner",
    packages=find_packages(),
    classifiers=[
        "Development Status :: 4 - Beta",
        "Environment :: X11 Applications :: GTK",
        "Intended Audience :: End Users/Desktop",
        "License :: OSI Approved :: MIT License",
        "Operating System :: POSIX :: Linux",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Topic :: System :: Networking",
        "Topic :: Utilities",
    ],
    python_requires=">=3.8",
    install_requires=requirements,
    entry_points={
        "console_scripts": [
            "nss-gui=main:main",
        ],
    },
    package_data={
        "": ["*.ui", "*.css"],
    },
    include_package_data=True,
)