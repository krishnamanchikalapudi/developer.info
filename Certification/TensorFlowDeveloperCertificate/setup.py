import setuptools

# Get the required libraries from the requirements.txt file
with open("requirements.txt", "r") as reqlibs:
    required_libs = reqlibs.read().splitlines()

# Get the long description from the README file
with open("README.md", "r") as readme:
    long_description = readme.read()

setuptools.setup(
    name='TFDC',
    version='0.1.0',
    description='TensorFlow Developer Certification preparation',
    long_description=long_description,
    long_description_content_type="text/markdown",
    url='https://www.linkedin.com/in/krishnamanchikalapudi/',
    classifiers=[
        'Development Status :: 0.1',
        'Programming Language :: Python :: 3.8'
    ],
    author='Krishna Manchikalapudi',
    author_email='krishna.manchikalapudi@yahoo.com',
    license='MIT License',
    packages=setuptools.find_packages(),
    install_requires=required_libs,
    zip_safe=False
)
