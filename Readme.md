D’abord, on crée un réseau docker pour l’entreprise : 	
docker network create IC-GROUP

![image](https://user-images.githubusercontent.com/74649986/201877594-128e9c73-bc0b-41ac-ac1a-be20f64412d7.png)

Ensuite on fait un docker file pour build



FROM python:3.6-alpine
run  pip install flask==1.1.2
ADD . /opt/
WORKDIR /opt
EXPOSE 8080
VOLUME /opt/data
ENTRYPOINT ["python","./app.py"]


Puis on build 
docker build -t ic-group .
On voit bien que l’image est créée.

![image](https://user-images.githubusercontent.com/74649986/201877761-88a0b020-e71c-4212-882d-a4f5cb778a48.png)


On lance le conteneur test et on peut aller sur la page.
docker run --network=IC-GROUP -p 8080:80 ic-webapp

![image](https://user-images.githubusercontent.com/74649986/201880058-697b6e51-60c7-4fda-8062-9f9c1eb51aac.png)



2.
On crée un registre privé pour notre réseau.
Apparemment il faut plus aller vers 4001:5000		 	 	 		

docker run -d -p 8081:80 --net IC-GROUP --name registry-ic registry:2 
![image](https://user-images.githubusercontent.com/74649986/201880378-1a0101d6-62c1-49be-a05e-fbf037749403.png)

Ensuite on ajoute une interface web à ce registre. 
docker run -d --net IC-GROUP -p 8082:80 -e REGISTRY_URL=http://registry-ic:80 -e DELETE_IMAGES=true -e REGISTRY_TITLE="IC REGISTRY" joxit/docker-registry-ui:static

![image](https://user-images.githubusercontent.com/74649986/201880636-9929c639-3542-4138-9a68-51b3c5d2ae3c.png)

![image](https://user-images.githubusercontent.com/74649986/201880768-718fa34b-25e3-458c-a343-fadbb7bfc746.png)

![image](https://user-images.githubusercontent.com/74649986/201880843-a763f1be-e3dc-4d54-9d51-97c43dd503fe.png)

Puis on le push sur docker Hub.
![image](https://user-images.githubusercontent.com/74649986/201880927-cf2a2717-07c8-4dda-a5e3-28a606305e00.png)
Dans notre compte docekrhub, on constate que l’image a bien été push
![image](https://user-images.githubusercontent.com/74649986/201881024-7b87e056-4580-4ec9-9ee3-6701ef8abc57.png)

3.

Docker-compose.yml:

version: '3'
services:
	web:
    image: odoo:14.0
    depends_on:
      - db
    ports:
      - "8069:8069"
  db:
    image: postgres:13
    environment:
      - POSTGRES_DB=postgres
      - POSTGRES_PASSWORD=odoo
      - POSTGRES_USER=odoo



 pas sur pour celui la


pgadmin:


   container_name: pgadmin_container


   image: dpage/pgadmin4


   environment:


     PGADMIN_DEFAULT_EMAIL: ${PGADMIN_DEFAULT_EMAIL:-pgadmin4@pgadmin.org}


     PGADMIN_DEFAULT_PASSWORD: ${PGADMIN_DEFAULT_PASSWORD:-admin}


     PGADMIN_CONFIG_SERVER_MODE: 'False'


   volumes:


      - pgadmin:/var/lib/pgadmin






   ports:


     - "${PGADMIN_PORT:-5050}:80"


   networks:


     - postgres


   restart: unless-stopped



