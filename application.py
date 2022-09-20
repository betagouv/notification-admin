from flask import Flask
from app import create_app

from dotenv import load_dotenv
load_dotenv()

application = Flask('app')

create_app(application)
