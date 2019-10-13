FROM centos:centos7

#add my files
ADD app.py /root/
ADD main.py /root/
RUN mkdir /root/templates
ADD templates/upload.html /root/templates
ADD templates/file-list.html /root/templates
RUN mkdir /root/uploads
RUN chmod 777 /root/uploads
RUN mkdir /root/processed
RUN chmod 777 /root/processed


RUN touch /root/processed/test1.txt
RUN touch /root/processed/test2.txt
RUN touch /root/processed/test3.txt
RUN touch /root/processed/test4.txt


#install pre-reqs
RUN yum -y install python3 shutil wget


#install python pre-reqs
RUN pip3 install --upgrade pip
RUN pip3 install flask app requests kafka

#get pre-staged files
RUN mkdir /root/data
RUN chmod 777 /root/data
#RUN wget https://www.dropbox.com/s/x0orqhrfihf6hsz/x.npy?dl=0 -O /root/data/X.npy --quiet
RUN touch /root/data/X.npy
RUN chmod 777 /root/data/X.npy

RUN wget https://www.dropbox.com/s/w7ckfpjac9ckkuw/y.npy?dl=0 -O /root/data/y.npy --quiet
RUN chmod 777 /root/data/y.npy


WORKDIR /root/
CMD python3 main.py
