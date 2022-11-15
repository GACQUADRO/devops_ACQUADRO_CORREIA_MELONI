FROM python:3.6-alpine
run  pip install flask==1.1.2
ADD . /opt/
WORKDIR /opt
EXPOSE 8080
VOLUME /opt/data
ENTRYPOINT ["python","./app.py"]
