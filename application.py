import os
import sentry_sdk
from dotenv import load_dotenv
from flask import Flask
from sentry_sdk.integrations.flask import FlaskIntegration
from sentry_sdk.integrations.redis import RedisIntegration

from app import create_app

load_dotenv()

sentry_sdk.init(
    dsn=os.environ.get("SENTRY_URL", ""),
    integrations=[
        FlaskIntegration(),
        RedisIntegration(),
    ],
    release="notify-admin@" + os.environ.get("GIT_SHA", ""),
)

application = Flask("app")

create_app(application)
