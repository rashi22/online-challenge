# aws-ec2-metadata-json

## What it does
- Query the metadata of an ec2 instance within AWS and provide a json formatted output. 


## We need an EC2 instance with python installed to run this script


## How to run
- Open the `src` folder
  - `cd aws-metadata-json/src`
- Run the script:
  - `python3 get_metadata.py`
  

## How it works
- It makes use of the http://169.254.169.254/latest/meta-data link-local address. Instance metatada is provided at this link, but only when you visit it from a running instance.
- A few simple Python scripts are used to extract the required information using the above API.
