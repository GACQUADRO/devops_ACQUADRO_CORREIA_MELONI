#   RAPPORT DEVOPS

SIMON MELONI | GREGOIRE ACQUADRO | SIMON CORREIA

## 1/ Conteneurisation de l’application web 

Tout d'abord nous allons installer docker

**apt-get install docker.io**

Et nous allons aussi cloner le git du projet

**git clone https://github.com/eazytraining/docker-exams-1.git**

Durant ce projet nous travaillons pour l'entreprise IC-GROUP, la première étape sera donc de créer le network :

**docker network create IC-GROUP**

![image](https://user-images.githubusercontent.com/74649986/201877594-128e9c73-bc0b-41ac-ac1a-be20f64412d7.png)

Ensuite nous allons devoir build une image ic-webapp avec des paramètres qui nous été donnés, pour se faire nous allons faire une fichier dockerfile adapté :



FROM python:3.6-alpine \
run  pip install flask==1.1.2\
ADD . /opt/ \
WORKDIR /opt \
EXPOSE 8080 \
VOLUME /opt/data \
ENTRYPOINT ["python","./docker-exams-1/app.py"] 


Il nous suffit de faire la commande build pour faire notre image.

**docker build -t ic-webapp .**

Et on voit que l’image a bien été créée.

![image](https://user-images.githubusercontent.com/74649986/201877761-88a0b020-e71c-4212-882d-a4f5cb778a48.png)


Pour pouvoir accéder à notre page, il nous faut un container, c'est ce qu'on fait avec un docker run, en indiquant le port voulu, le nom du network et l'image.

**docker run --network=IC-GROUP -p 8080:80 ic-webapp**

![image](https://user-images.githubusercontent.com/74649986/201880058-697b6e51-60c7-4fda-8062-9f9c1eb51aac.png)



## 2/ Docker Registry
On crée notre premier registre qu'on appelera "registry-ic" et sur le port 8081:80 : 	 	 		

**docker run -d -p 8081:80 --net IC-GROUP --name registry-ic registry:2**

![image](https://user-images.githubusercontent.com/74649986/201880378-1a0101d6-62c1-49be-a05e-fbf037749403.png)

Pour y accéder facilement on ajoute une interface web grâce à la commande qu'on nous a fournit

**docker run -d --net IC-GROUP -p 8082:80 -e REGISTRY_URL=http://registry-ic:80 -e DELETE_IMAGES=true -e REGISTRY_TITLE="IC REGISTRY" joxit/docker-registry-ui:static**

![image](https://user-images.githubusercontent.com/74649986/201880636-9929c639-3542-4138-9a68-51b3c5d2ae3c.png)

![image](https://user-images.githubusercontent.com/74649986/201880768-718fa34b-25e3-458c-a343-fadbb7bfc746.png)

![image](https://user-images.githubusercontent.com/74649986/201880843-a763f1be-e3dc-4d54-9d51-97c43dd503fe.png)

On se login au dockerhub avant de pouvoir push

**docker login**


Enfin on peut push, en commencant part tag puis docker push

![image](https://user-images.githubusercontent.com/74649986/201880927-cf2a2717-07c8-4dda-a5e3-28a606305e00.png)

On va sur docker hub pour vérifier que nous avons bien push, et on constate que tout est là :

![image](https://user-images.githubusercontent.com/74649986/201881024-7b87e056-4580-4ec9-9ee3-6701ef8abc57.png)

## 3/ docker-compose

On crée le fichier docker compose : \
nano Docker-compse.yml

Puis on y met les fichiers que l’on veut:\
Docker-compose.yml:

version: '3.3'\
services:\
    pgadmin:
        container_name: pgadmin
        image: dpage/pgadmin4
        networks:
            - IC-GROUP
        environment:
            - 'PGADMIN_DEFAULT_EMAIL=odoo@eazytraining.fr'
            - 'PGADMIN_DEFAULT_PASSWORD=odoo_pgadmin_password'
        ports:
            - "5050:80"
        volumes:
            - ${PWD}/servers.json:/pgadmin4/servers.json
            - 'pgadmin_data:/var/lib/pgadmin'
    ic-webapp:
        container_name: ic-webapp
        ports:
            - "8080:8080"
        environment:
            - "ODOO_URL=http://localhost:8069/"
            - "PGADMIN_URL=http://localhost:5050/"
        image: 'simon6892/test-ic-webapp:version'
        networks:
            - IC-GROUP
    postgres:
        environment:
            - POSTGRES_USER=odoo_user
            - POSTGRES_PASSWORD=odoo_password
            - POSTGRES_DB=postgres
        networks:
            - IC-GROUP
        volumes:
            - 'pgdata:/var/lib/postgresql/data'
        container_name: postgres
        image: 'postgres:10'
        ports:
            - '5432:5432'
    odoo:
        depends_on:
            - postgres
        ports:
            - '8069:8069'
        container_name: odoo
        networks:
            - IC-GROUP
        volumes:
            - '/data_docker/config:/etc/odoo'
            - '/data_docker/addons:/mnt/extra-addons'
            - 'odoo-web-data:/var/lib/odoo'
        environment:
            - USER=odoo_user
            - PASSWORD=odoo_password
            - HOST=postgres
        image: odoo:13.0
volumes:
    odoo-web-data:
    pgdata:
    pgadmin_data:
networks:
    IC-GROUP:
      driver: bridge



On peut ensuite l’executer:
docker-compose up -d

Docker va télécharger les différents applications.

