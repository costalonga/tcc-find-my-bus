import os
import json
import boto3
import requests
import traceback
from time import sleep
from datetime import datetime

# Get the service resource.
# dynamo_resource = boto3.resource('dynamodb')
dynamo_client = boto3.client('dynamodb')

# URLs
# - http://dadosabertos.rio.rj.gov.br/apiTransporte/apresentacao/rest/index.cfm/obterTodasPosicoes
# - http://dadosabertos.rio.rj.gov.br/apiTransporte/apresentacao/rest/index.cfm/onibus/315
# - http://dadosabertos.rio.rj.gov.br/apiTransporte/apresentacao/rest/index.cfm/obterPosicoesDaLinha/315
# - http://dadosabertos.rio.rj.gov.br/apiTransporte/apresentacao/rest/index.cfm/obterPosicoesDoOnibus/C47695

def convert_dtrio_timestamp(datario_timestamp):
    datario_timestamp = datario_timestamp.split(' ')
    datario_timestamp[0] = datario_timestamp[0].split('-')
    year = datario_timestamp[0][2]
    month = datario_timestamp[0][0]
    day = datario_timestamp[0][1]
    time = datario_timestamp[1]
    return "{}/{}/{} {}".format(day, month, year, time)


def save_data(resp_dtrio: dict, id: int, request_type: str):
    if request_type.lower() == "linha":
        file_name = 'datario-get-linha-{}.json'.format(id)
    else:
        file_name = 'datario-get-onibus-{}.json'.format(id)
    curr_dir = os.getcwd()
    file_path = os.path.join(curr_dir, file_name)

    if os.path.exists(file_path) and os.stat(file_path).st_size != 0:
        with open(file_path, 'a') as f:
            f.write(',\n')
    with open(file_path, 'a') as f:
        json.dump(resp_dtrio, f)


def make_request(id_linha):
    resp_dtrio = None
    url_dtrio = 'http://dadosabertos.rio.rj.gov.br/apiTransporte/apresentacao/rest/index.cfm/onibus/{}'.format(id_linha)
    try:
        resp_dtrio = requests.get(url_dtrio)
        print("[SUCCESS]")
    except requests.ConnectionError:
        print(str.format("[Connection Error] at {} - DataRio API not available. Reattempting request in 5 minutes",
                         datetime.strftime(datetime.now(), "%d/%m/%Y %H:%M")))
        sleep(60 * 5)
    except Exception as e:
        traceback.print_exc(e)
        sleep(60 * 5)

    if resp_dtrio:
        # Write to DynamoDB
        resp_dtrio = resp_dtrio.json()['DATA']
        # resp_dtrio = resp_dtrio['DATA']
        table_name = str.format("data-rio-{}", id_linha)
        for row in resp_dtrio:
            try:
                response = dynamo_client.put_item(
                    TableName=table_name,
                    Item={
                        "id": {"S": row[1]},
                        "datahora": {"S": convert_dtrio_timestamp(row[0])},
                        "lat": {"N": str(row[3])},
                        "lon": {"N": str(row[4])},
                        "direcao": {"N": str(row[5])}
                    }
                )
            except Exception as e:
                traceback.print_exc(e)



if __name__ == '__main__':
    id_linha = 315
    # id_linha = 410

    url_dtrio = 'http://dadosabertos.rio.rj.gov.br/apiTransporte/apresentacao/rest/index.cfm/onibus/{}'.format(id_linha)
    make_request(id_linha)


    # while True:
    #     resp_dtrio = None
    #     try:
    #         resp_dtrio = requests.get(url_dtrio)
    #         print("[SUCCESS]")
    #     except requests.ConnectionError:
    #         print(str.format("[Connection Error] at {} - DataRio API not available. Reattempting request in 5 minutes",
    #                          datetime.strftime(datetime.now(), "%d/%m/%Y %H:%M")))
    #         sleep(60*5)
    #     except Exception as e:
    #         traceback.print_exc(e)
    #         sleep(60*5)
    #
    #     if resp_dtrio:
    #         resp_dtrio = resp_dtrio.json()['DATA']
    #
    #         resp = dict()
    #         now = datetime.strftime(datetime.now(), "%d/%m/%Y %H:%M")
    #         resp[now] = []
    #         for i in resp_dtrio:
    #             tmp = dict()
    #             tmp['id'] = i[1]
    #             tmp['dt'] = convert_dtrio_timestamp(i[0])
    #             tmp['lat'] = i[3]
    #             tmp['lon'] = i[4]
    #             tmp['direcao'] = i[6]
    #             resp[now].append(tmp)
    #         print(resp)
    #         save_data(resp, id_linha, request_type)
    #         sleep(60*2)

        # return resp

        # while True:
        #     now = datetime.strftime(datetime.now(), "%d/%m/%Y %H:%M")
        #     print(now)
        #     sleep(60*2)

# NOTE: Itinerario Downloader URL:
# dadosabertos.rio.rj.gov.br/apiTransporte/Apresentacao/csv/gtfs/onibus/percursos/gtfs_linha<LINHA>-shapes.csv
# Ex: dadosabertos.rio.rj.gov.br/apiTransporte/Apresentacao/csv/gtfs/onibus/percursos/gtfs_linha410-shapes.csv
