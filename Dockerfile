FROM centos:centos7

#add my files
ADD app.py /root/
ADD main.py /root/
RUN mkdir /root/templates
ADD templates/upload.html /root/templates
RUN mkdir /root/uploads

#install pre-reqs
RUN yum -y install python3 python3-devel shutil


#install python pre-reqs
RUN pip3 install --upgrade pip
RUN pip3 install flask app requests

#get pre-staged files
RUN mkdir /root/data
RUN wget https://www.dropbox.com/s/x0orqhrfihf6hsz/x.npy?dl=0 -O /root/data/X.npy --quiet
RUN wget https://www.dropbox.com/s/w7ckfpjac9ckkuw/y.npy?dl=0 -O /root/data/y.npy --quiet

WORKDIR /root/
CMD python3 main.py
