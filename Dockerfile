FROM registry.access.redhat.com/ubi7/python36:latest

#add my files
ADD app.py /root/
ADD main.py /root/
RUN mkdir /root/templates
ADD templates/upload.html /root/templates
ADD templates/file-list.html /root/templates
RUN mkdir /root/static
ADD static/mario_banner.jpg /root/static

RUN mkdir /root/uploads
RUN chmod 777 /root/uploads
RUN mkdir /root/processed
RUN chmod 777 /root/processed

#install pre-reqs
RUN yum -y --disableplugin=subscription-manager install python3 shutil wget


#install python pre-reqs
RUN pip3 install --upgrade pip
RUN pip3 install flask app requests kafka jsonify

#get pre-staged files
RUN mkdir /root/data
RUN chmod 777 /root/data

RUN wget https://www.dropbox.com/s/x0orqhrfihf6hsz/x.npy?dl=0 -O /root/data/X.npy --quiet
RUN chmod 777 /root/data/X.npy

RUN wget https://www.dropbox.com/s/w7ckfpjac9ckkuw/y.npy?dl=0 -O /root/data/y.npy --quiet
RUN chmod 777 /root/data/y.npy


WORKDIR /root/
CMD python3 main.py
