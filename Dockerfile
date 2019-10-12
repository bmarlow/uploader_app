FROM centos:centos7

#add my files
ADD app.py /root/
ADD main.py /root/
RUN mkdir /root/templates
ADD templates/upload.html /root/templates
RUN mkdir /root/uploads

#install pre-reqs
RUN yum -y install python3 python3-devel


#install python pre-reqs
RUN pip3 install --upgrade pip
RUN pip3 install flask app

WORKDIR /root/
CMD python main.py
