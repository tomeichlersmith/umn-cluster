"""Setup this python package"""

from setuptools import setup

setup(
    name='umn_htcondor',
    version='0.1.0',
    description='UMN-specific wrapper around HTCondor',
    url='https://github.com/tomeichlersmith/umn-cluster',
    author='Tom Eichlersmith',
    author_email='eichl008@umn.edu',
    license='MIT',
    packages=['umn_htcondor'],
    install_requires=['htcondor'],
    scripts=['scripts/submit_jobs']
)
