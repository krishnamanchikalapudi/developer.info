import os, ssl, urllib.request

# BEGIN: fix Python or Notebook SSL CERTIFICATE_VERIFY_FAILED
import ssl
if (not os.environ.get('PYTHONHTTPSVERIFY', '') and getattr(ssl, '_create_unverified_context', None)):
    ssl._create_default_https_context = ssl._create_unverified_context
# END: fix Python or Notebook SSL CERTIFICATE_VERIFY_FAILED

def retrieve_data(remote_file, local_file):
    if not os.path.exists(local_file) and not os.path.isfile(local_file):
        urllib.request.urlretrieve(remote_file, local_file)
        print(f"File: {local_file} download complete")
    else:
        print(f"File: '{local_file}' already exists!")


# main method
if __name__ == '__main__':
    # Downloading csv file
    remote_filename_concrete = 'https://archive.ics.uci.edu/ml/machine-learning-databases/concrete/slump/slump_test.data'
    local_filename_concrete = './data/concrete_slump.csv'
    retrieve_data(remote_filename_concrete, local_filename_concrete)

    # Downloading json file
    remote_filename_timeseries = 'https://www.ncdc.noaa.gov/cag/national/time-series/110-pcp-ytd-12-1895-2021.json'
    local_filename_timeseries = './data/national_timeseries.json'

    retrieve_data(remote_filename_timeseries, local_filename_timeseries)
