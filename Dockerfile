FROM python:3.9-alpine

ENV PYTHONDONTWRITEBYTECODE 1

RUN apk add --no-cache bash git nodejs npm make gcc linux-headers musl-dev g++ && rm -rf /var/cache/apk/*

# update pip
RUN python -m pip install wheel

# -- Install Application into container:
RUN set -ex && mkdir /app

WORKDIR /app

COPY requirements.txt requirements_for_test.txt .

RUN pip3 install -r requirements_for_test.txt

COPY package.json package-lock.json .snyk /app/
RUN npm ci

COPY . /app

RUN make babel

RUN npm run build

ENV PORT=6012

ARG ADMIN_COMMIT
ENV GIT_SHA=${GIT_SHA}

ENTRYPOINT ["./entrypoint.sh"]

CMD "gunicorn -c gunicorn_config.py application"
