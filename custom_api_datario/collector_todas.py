import os
import boto3
import json
from datetime import datetime
import traceback

CURR_DIR = os.getcwd()
INPUT_DIR = os.path.join(CURR_DIR, 'dtrio_get_linhas')
REAL_TIME_TABLE = "custom-data-rio-real-time"
HISTORIC_TABLE = "historic-data"  # with LSI

# Get the service resource.
dynamo_resource = boto3.resource('dynamodb')
dynamo_client = boto3.client('dynamodb')


def list_files_from_dir(tmp_dir, end_sufix:str=".json"):
    files = list()
    for file in os.listdir(tmp_dir):
        full_path = os.path.join(tmp_dir, file)
        if os.path.isfile(full_path) and full_path.endswith(end_sufix):
            print(file)
            files.append(full_path)
    return files

def get_linha(file_path: str):
    file = file_path.split('/')
    file = file[len(file) - 1]
    linha = file.split('-')
    linha = linha[len(linha) - 1].split('.')[0]
    return linha

def convert_dtrio_timestamp(dt_stamp: str):
    tmp = datetime.strptime(dt_stamp, "%m-%d-%Y %I:%M:%S")
    return tmp.strftime("%d/%m/%Y %I:%M:%S")

def upload_file(file_path: str):
    status = None
    linha = get_linha(file_path)
    with open(file_path, 'r') as f:
        file_data = f.read()
        json_data = json.loads(file_data)
        print(type(json_data), len(json_data), json_data)
        print(json_data['DATA'])
        for request in json_data['DATA']:
            try:
                dt = convert_dtrio_timestamp(request[0])
                epoch = datetime.strptime(dt, "%d/%m/%Y %H:%M:%S").timestamp()  # DATAHORA
                item = {
                    "linha": {"S": linha},
                    "timestamp": {"N": str(epoch)},
                    "id": {"S": request[1]},  # ORDEM
                    "latitude": {"N": str(request[3])},
                    "longitude": {"N": str(request[4])},
                    "datahora": {"S": dt}
                }
                response = dynamo_client.put_item(
                    TableName=REAL_TIME_TABLE,
                    Item=item
                )
                status = response['ResponseMetadata']['HTTPStatusCode']
                if (status != 200):
                    print(response)
                    raise Exception('[ERROR] Item was not inserted on table: {}'.format(item))
            except Exception as e:
                traceback.print_exc(e)
        
    if status == 200:
        os.remove(file_path)

def execute_all():
    files_path_lst = list_files_from_dir(INPUT_DIR)
    for file_to_read in files_path_lst:
        upload_file(file_to_read)

if __name__ == '__main__':
    execute_all()

