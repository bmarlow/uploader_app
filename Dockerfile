FROM centos:centos7

#add my files
ADD app.py /tmp/
ADD main.py /tmp/
RUN mkdir /tmp/templates
ADD templates/upload.html /tmp/templates
ADD templates/file-list.html /tmp/templates
RUN mkdir /tmp/static
ADD static/mario_banner.jpg /tmp/static
ADD static/magic_word.gif /root/static
ADD templates/naughty.html /root/templates

RUN mkdir /tmp/uploads
RUN chmod 777 /tmp/uploads
RUN mkdir /tmp/processed
RUN chmod 777 /tmp/processed

#install pre-reqs
RUN yum -y install wget python3


#install python pre-reqs
RUN pip3 install --upgrade pip
RUN pip3 install flask app requests kafka jsonify

#get pre-staged files
RUN mkdir /tmp/data
RUN chmod 777 /tmp/data

RUN wget https://www.dropbox.com/s/x0orqhrfihf6hsz/x.npy?dl=0 -O /tmp/data/X.npy --quiet
RUN chmod 777 /tmp/data/X.npy

RUN wget https://www.dropbox.com/s/w7ckfpjac9ckkuw/y.npy?dl=0 -O /tmp/data/y.npy --quiet
RUN chmod 777 /tmp/data/y.npy


WORKDIR /root/
CMD python3 /tmp/main.py
