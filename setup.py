from setuptools import setup, find_packages

setup(
    name='cc11_fix',
    version='0.1',
    packages=find_packages(),
    install_requires=[
        'mido',
    ],
    entry_points={
        'console_scripts': [
            'filter-cc11=filter_cc11:main',
        ],
    },
)
