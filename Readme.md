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
![image](https://user-images.githubusercontent.com/74649986/201877761-88a0b020-e71c-4212-882d-a4f5cb778a48.png)

Puis on build 
docker build -t ic-group .
On voit bien que l’image est créée.


On lance le conteneur test et on peut aller sur la page.
docker run --network=IC-GROUP -p 8080:80 ic-webapp




2.
On crée un registre privé pour notre réseau.
Apparemment il faut plus aller vers 4001:5000		 	 	 		

docker run -d -p 8081:80 --net IC-GROUP --name registry-ic registry:2 


Ensuite on ajoute une interface web à ce registre. 
docker run -d --net IC-GROUP -p 8082:80 -e REGISTRY_URL=http://registry-ic:80 -e DELETE_IMAGES=true -e REGISTRY_TITLE="IC REGISTRY" joxit/docker-registry-ui:static







Puis on le push sur docker Hub.

Dans notre compte docekrhub, on constate que l’image a bien été push
