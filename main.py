import os
import random
from flask import Flask, send_file
import yaml
import functools


app = Flask(__name__)

def load_routes_from_config():
    with open('/config.yaml', 'r') as config_file:
        config = yaml.safe_load(config_file)
        routes = config.get('routes', [])
        for route in routes:
            url = route.get('url')
            method = route.get('method')
            # function_name = route.get('function')

            # Get the image directory from the configuration
            image_dir = route.get('image_dir')
            # function = globals().get(function_name)
            
            # If all required attributes are present
            if url and method and image_dir:
                # Create a partial function with the image directory as an argument
                partial_random_image = functools.partial(random_image, image_dir=image_dir)
                # Set a custom name for the partial function based on the image directory
                partial_random_image.__name__ = f"random_image_{image_dir.replace('/', '_')}"
                # Add the URL route to the Flask app, using the partial function as the view function
                app.add_url_rule(url, view_func=partial_random_image, methods=[method])
                # Print information about the added route
                print(f"Route added: URL={url}, Method={method}, Directory={image_dir}")


def random_image(image_dir):
    images = os.listdir(image_dir)
    random_image = random.choice(images)
    return send_file(os.path.join(image_dir, random_image), mimetype='image/jpeg')


if __name__ == '__main__':
    load_routes_from_config()
    app.run(host='0.0.0.0', port=5000)
