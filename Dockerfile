FROM registry.access.redhat.com/ubi7/python-36:latest

#add my files
ADD app.py /tmp/
ADD main.py /tmp/
RUN mkdir /tmp/templates
ADD templates/upload.html /tmp/templates
ADD templates/file-list.html /tmp/templates
RUN mkdir /tmp/static
ADD static/mario_banner.jpg /tmp/static

RUN mkdir /tmp/uploads
RUN chmod 777 /tmp/uploads
RUN mkdir /tmp/processed
RUN chmod 777 /tmp/processed

#install pre-reqs
RUN sudo yum -y --disableplugin=subscription-manager install shutil wget


#install python pre-reqs
RUN pip3 install --upgrade pip
RUN pip3 install flask app requests kafka jsonify

#get pre-staged files
RUN mkdir /tmp/data
RUN chmod 777 /tmp/data

RUN wget https://www.dropbox.com/s/x0orqhrfihf6hsz/x.npy?dl=0 -O /root/data/X.npy --quiet
RUN chmod 777 /tmp/data/X.npy

RUN wget https://www.dropbox.com/s/w7ckfpjac9ckkuw/y.npy?dl=0 -O /root/data/y.npy --quiet
RUN chmod 777 /tmp/data/y.npy


WORKDIR /root/
CMD python3 main.py
