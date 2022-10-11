import importlib
import os

import pytest

from app import config


def cf_conf():
    os.environ['API_HOST_NAME'] = 'cf'


@pytest.fixture
def reload_config(os_environ):
    """
    Reset config, by simply re-running config.py from a fresh environment
    """
    old_env = os.environ.copy()
    os.environ.clear()

    yield

    os.environ.clear()
    for k, v in old_env.items():
        os.environ[k] = v
    importlib.reload(config)
