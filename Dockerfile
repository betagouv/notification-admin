FROM python:3.9-alpine

ENV PYTHONDONTWRITEBYTECODE 1

RUN apk add --no-cache bash git nodejs npm make gcc linux-headers musl-dev g++ libffi-dev proj-util proj-dev geos-dev && rm -rf /var/cache/apk/*

RUN python -m pip install --upgrade pip
RUN python -m pip install pipenv

WORKDIR /app

COPY Pipfile Pipfile.lock .
RUN pipenv install --dev --system

COPY package.json package-lock.json .
RUN npm ci

COPY . /app

RUN npm run build

ENV PORT=6012

ARG ADMIN_COMMIT
ENV GIT_SHA=${GIT_SHA}

ENTRYPOINT ["./entrypoint.sh"]

CMD "gunicorn -c gunicorn_config.py application"
