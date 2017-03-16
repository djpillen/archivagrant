import requests
import json
import os
from os.path import join

latest_release_api = 'https://api.github.com/repos/archivesspace/archivesspace/releases/latest'

save_dir = '/home/vagrant'

if not os.path.exists(save_dir):
	os.makedirs(save_dir)

def extract_release(zip_file):
	# Use os.system instead of the python zipfile library to preserve permissions
	os.system('unzip ' + zip_file + ' -d /home/vagrant/')

with requests.Session() as s:
	print "Finding the latest ArchivesSpace release"
	latest_release_json = requests.get(latest_release_api).json()
	latest_release_name = latest_release_json['assets'][0]['name']
	latest_release_url = latest_release_json['assets'][0]['browser_download_url']
	print "Latest release url:",latest_release_url
	print "Latest release name:",latest_release_name
	zip_file = join(save_dir,latest_release_name)
	unzipped_file = join(save_dir,'archivesspace')
	if not os.path.exists(zip_file) and not os.path.exists(unzipped_file):
		print "Downloading latest release"
		latest_release_zip = s.get(latest_release_url)
		with open(zip_file,'wb') as outfile:
			print "Saving latest release to {0}".format(zip_file)
			outfile.write(latest_release_zip.content)
		print "Extracting latest release"
		extract_release(zip_file)
	elif os.path.exists(zip_file) and not os.path.exists(unzipped_file):
		print "Latest release downloaded but not extracted"
		print "Extracting..."
		extract_release(zip_file)
	else:
		print "Latest release already downloaded and extracted"
