import requests
import time
import json
from pprint import pprint

# This script is used to setup BHL ArchivesSpace defaults for running test migrations

def test_connection():
	try:
		requests.get('http://localhost:8089')
		print('Connected!')
		return True

	except requests.exceptions.ConnectionError:
		print('Connection error. Trying again in 10 seconds.')

is_connected = test_connection()

while not is_connected:
	time.sleep(10)
	is_connected = test_connection()

auth = requests.post('http://localhost:8089/users/admin/login?password=admin').json()
session = auth['session']
headers = {'X-ArchivesSpace-Session':session}

bhl_repo = {
		'name':'Bentley Historical Library',
		'org_code':'MiU-H',
		'repo_code':'BHL',
		'parent_institution_name':'University of Michigan'
		}

post_repo = requests.post('http://localhost:8089/repositories',headers=headers,data=json.dumps(bhl_repo)).json()
print(post_repo)

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
	print(profile_post)

mhc_classification = {'title':'Michigan Historical Collections','identifier':'MHC'}
uarp_classification = {'title':'University Archives and Records Program','identifier':'UARP'}

for classification in [mhc_classification, uarp_classification]:
	classification_post = requests.post('http://localhost:8089/repositories/2/classifications',headers=headers,data=json.dumps(classification)).json()
	print(classification_post)

def add_enum_values(enum_set_id, new_values_to_add):
	enum_address = 'http://localhost:8089/config/enumerations/{}'.format(enum_set_id)
	existing_enums_json = requests.get(enum_address, headers=headers).json()
	existing_enums_json["values"].extend(new_values_to_add)
	pprint(requests.post(enum_address, headers=headers, data=json.dumps(existing_enums_json)).json())
	
add_enum_values(23, ['lcnaf', 'lctgm', 'aacr2'])  # subject sources
add_enum_values(4, ['lcnaf'])  # name sources
add_enum_values(55, ["on file", "pending", "sent", "n/a", "other"])  # user defined enum 1 values (gift agreement status)

repo_preferences = {
	'repository':{'ref':'/repositories/2'},
	'defaults':{'publish':True}
	}

repo_preferences_post = requests.post('http://localhost:8089/repositories/2/preferences',headers=headers, data=json.dumps(repo_preferences)).json()
print(repo_preferences_post)
