import random
import yaml


PROPERTY_LENGTH = 'length'
MIN_LENGTH=8


# Omit hardly distinguishable characters like: I, l, 0 and O
CHARACTERS = 'abcdefghijkmnopqrstuvwxyzABCDEFGHJKMNPQRSTUVWXYZ123456789$#@^!'


class InputError(Exception):
  """Raised when input properties are unexpected."""


def GenerateConfig(context):
  """Entry function to generate the DM config."""
  props = context.properties
  length = props.setdefault(PROPERTY_LENGTH, MIN_LENGTH)


  content = {
    'resources': [],
    'outputs': [{
      'name': 'string',
      'value': GeneratePassword(length)
    }]
  }
  return yaml.dump(content)


def GeneratePassword(length=MIN_LENGTH):
  """Generates a random string."""
  if length < MIN_LENGTH:
    raise InputError('Password length must be at least %d' % MIN_LENGTH)
  return ''.join(random.choice(CHARACTERS) for _ in range(length))
