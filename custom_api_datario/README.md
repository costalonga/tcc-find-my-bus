# Custom API DataRio

Conjunto de scripts Python utilizados para criar abstração da API DataRio. 

Esses scripts devem ser inseridos na AWS através de Dockerfile ou .zip, para criar funções Lambda que por sua vez irão ser utilizadas pelo Amazon API Gateway (para criar APIs HTTP, para fazer leituras as tabelas do DynamoDB) e pelo Amazon CloudWatch (para executar um script na AWS periodicamente, coletar dados da API DataRio e armazenar em tabelas do DynamoDB) funcione de acordo com o esperado funções Lambda. 