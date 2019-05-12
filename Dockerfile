# Pull base image
FROM python:3.7-alpine

RUN apk --update --upgrade add gcc musl-dev jpeg-dev zlib-dev libffi-dev cairo-dev pango-dev gdk-pixbuf

# make psycopg2-binary install on alpine
RUN apk update && apk add postgresql-dev gcc python3-dev musl-dev

# Set environment varibles
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set work directory
WORKDIR /code

# Install dependencies
ADD requirements.txt /code/
RUN pip install -r requirements.txt

# Copy project
COPY . /code/