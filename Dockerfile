FROM python

RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
RUN python get-pip.py
RUN pip install ariadne flask mysql-connector-python email-validator
RUN mkdir /jmdcws

WORKDIR /jmdcws

CMD ["python","app.py"]
