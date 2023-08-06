# Hookme

## Instalação
  No projeto consta um arquivo docker-compose.yml caso possua o docker instalado basta rodar:
```
docker-compose up -d --build
```
 Para rodar manualmente é necessario instalar as dependencias:
 ```
mix deps.get
```
E rodar:
```
mix run --no-halt
```

## Sobre as escolhas tecnicas
Quando surge o desafio de criar um serviço para agregar informações de uma serie de endpoint e envia-los de forma assincrona começamos a pensar nas tecnologias, e quais seriam o estado da arte e as primeiras que nos veem a mente são
 - **phoenix** o canhão do desenvolvimento web com alta gama de funcionalidades
 - **oban** para rodar diversos jobs assincronos e com retry e alta resiliencia
 - **ETS** para um caching super eficiente na maquina virtual do Erlang
Mas analisando mais cuidadosamente o problema fiz as seguintes perguntas:
 - Vou lidar com muitos endpoints, sockets, channels e tudo o que há de bom?
     - Resposta: Não na verdade só terei um endpoint para enviar o **username** e o **repository** então uma abordagem mais simples talvez deva ser usar o **Plug** ao invés do phoenix pela simplicidade ao mesmo tempo em que o Plug é a base do phoenix que nada mais é que uma composição de simples plugs
 - A abordagem mais simples inicialmente é usar Oban com todo o tempo inicial de configuração e de adicionar um Postgres?
     - Resposta: Não, na verdade a maneira mais simples e incremental seria usar o modulo Task e criar uma task assincrona para cada job e adicionar uma politica de retentativa caso uma task não consiga finalizar com sucesso o envio de dados para o webhook
 - Manter um caching de usuarios/repositorios para evitar ddos e tambem manter um caching de usuarios buscados na api do github é muito essencial para performance, mas precisamos iniciar com um ETS?
     - Resposta: Como não vamos iniciar de maneira mais robusta em mais de uma maquina podemos tomar uma abordagem de usar Agents para o controle de informações visto que é a finalidade desse modulo guardar estados e se necessario adicionar um maximo de jobs no cache
