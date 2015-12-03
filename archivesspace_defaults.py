import requests
import time
import json

def test_connection():
	try:
		requests.get('http://localhost:8089')
		print 'Connected!'
		return True

	except requests.exceptions.ConnectionError:
		print 'Connection error. Trying again in 10 seconds.'

is_connected = test_connection()

while not is_connected:
	time.sleep(10)
	is_connected = test_connection()

auth = requests.post('http://localhost:8089/users/admin/login?password=admin').json()
session = auth['session']
headers = {'X-ArchivesSpace-Session':session}

bhl_repo = {
		'name':'Bentley Historical Library',
		'org_code':'Mi-U',
		'repo_code':'BHL',
		'parent_institution_name':'University of Michigan'
		}

post_repo = requests.post('http://localhost:8089/repositories',headers=headers,data=json.dumps(bhl_repo)).json()
print post_repo

base_profile = {
	'name':'',
	'extent_dimension':'height',
	'dimension_units':'inches',
	'height':'0',
	'width':'0',
	'depth':'0'
}

profile_names = ['box','folder','volume','reel','map-case','panel','sound-disc','tube','item','object','bundle']

for profile_name in profile_names:
	container_profile = base_profile
	container_profile['name'] = profile_name
	profile_post = requests.post('http://localhost:8089/container_profiles',headers=headers,data=json.dumps(container_profile)).json()
	print profile_post

mhc_classification = {'title':'Michigan Historical Collections','identifier':'MHC'}
uarp_classification = {'title':'University Archives and Records Program','identifier':'UARP'}

for classification in [mhc_classification, uarp_classification]:
	classification_post = requests.post('http://localhost:8089/repositories/2/classifications',headers=headers,data=json.dumps(classification)).json()
	print classification_post

subject_sources = requests.get('http://localhost:8089/config/enumerations/23',headers=headers).json()
subject_sources['values'].extend(['lcnaf','lctgm','aacr2'])
update_subject_sources = requests.post('http://localhost:8089/config/enumerations/23',headers=headers,data=json.dumps(subject_sources)).json()
print update_subject_sources

name_sources = requests.get('http://localhost:8089/config/enumerations/4',headers=headers).json()
name_sources['values'].append('lcnaf')
update_name_sources = requests.post('http://localhost:8089/config/enumerations/4',headers=headers,data=json.dumps(name_sources)).json()
print update_name_sources

repo_preferences = requests.get('http://localhost:8089/repositories/2/preferences',headers=headers).json()

for preference in repo_preferences:
	if 'user_id' not in preference:
		global_defaults = preference

global_defaults_uri = global_defaults['uri']
global_defaults['defaults']['publish'] = True

update_defaults = requests.post('http://localhost:8089' + global_defaults_uri, headers=headers, data=json.dumps(global_defaults)).json()
post update_defaults