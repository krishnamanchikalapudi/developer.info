import setuptools

with open("README.md", "r") as fh:
    long_description = fh.read()

setuptools.setup(
    name='GenerateSBOMreport',
    version='0.1.0',
    description='Generate SBOM HTML report in the gh-pages branch',
    long_description=long_description,
    long_description_content_type="text/markdown",
    url='',
    classifiers=[
        'Development Status :: 0.1',
        'Programming Language :: Python :: 3.12'
    ],
    author='Krishna Manchikalapudi',
    license='MIT License',
    packages=setuptools.find_packages(),
    install_requires=[
        'requests',
        'pandas',
        'tqdm'
    ]
)