FROM python:3.9-alpine

ENV PYTHONDONTWRITEBYTECODE 1

RUN apk add --no-cache bash git nodejs npm make gcc linux-headers musl-dev g++ && rm -rf /var/cache/apk/*

WORKDIR /app

RUN python -m pip install pipenv

COPY Pipfile Pipfile.lock .
RUN pipenv install --dev --system

COPY package.json package-lock.json .snyk .
RUN npm ci

COPY . /app

RUN make babel

RUN npm run tailwind

ENV PORT=6012

ARG ADMIN_COMMIT
ENV GIT_SHA=${GIT_SHA}

ENTRYPOINT ["./entrypoint.sh"]

CMD "gunicorn -c gunicorn_config.py application"
