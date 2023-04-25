from locust import User, SequentialTaskSet, task, between
import random
import requests
from requests.auth import HTTPBasicAuth
import json

class OrderedUserWithOrders(User):
  wait_time = between(1,2)
  fixed_count = 1
  
  @task
  class SequencedTasks(SequentialTaskSet):

    wait_time = between(1,2)

    def __init__(self, parent):
        super().__init__(parent)
        sockshopurl = (self.user.host)
        sockShopClient = SockShopClient(sockshopurl)
        self.sockShopClient = sockShopClient
        self.sockShopUser = {}
        self.sockShopCart = {}
        self.sockShopItem = {}
        self.sockShopCatalogue = {}

    @task
    def on_start(self):
        sockShopClient = self.sockShopClient
        # register
        # TODO generate random names
        self.sockShopUser = {
                    "username": f"JohnDoe",
                    "password": "password",
                    "email": "email@email.com",
                    "firstName": "John",
                    "lastName": "Doe"
                }
        sockShopClient.register(username=self.sockShopUser['username'], password=self.sockShopUser['password'], email=self.sockShopUser['email'],
                        firstName=self.sockShopUser['firstName'], lastName=self.sockShopUser['lastName'])
        sockShopClient.add_address(street="Via", postcode="20100", city="Milan", country="Italy", number="0")
        sockShopClient.add_credit_card(longnum="12344566788", expires="01/22", ccv="123")
        sockShopClient.login(self.sockShopUser['username'], self.sockShopUser['password'])
    
    @task
    def browse(self):
        sockShopClient = self.sockShopClient
        tags = sockShopClient.get_tags()
        _tags = random.choices(tags, k=random.randint(0, len(tags)))
        self.sockShopCatalogue = sockShopClient.get_catalogue(tags=_tags)
        if len(self.sockShopCatalogue) == 0:
            return
        self.sockShopItem = random.choice(self.sockShopCatalogue)
        sockShopClient.browse_to_item(self.sockShopItem['id'])

    @task
    def get_cart(self):
        self.sockShopCart = self.sockShopClient.get_cart()
    
    @task
    def add_to_cart(self):
        if len(self.sockShopCatalogue) == 0:
            return
        self.sockShopItem = random.choice(self.sockShopCatalogue)
        self.sockShopClient.add_to_cart(self.sockShopItem['id'])
    
    @task
    def checkout(self):
        if not self.sockShopCart:
            return
        self.sockShopClient.checkout()

class SockShopClient(object):
    def __init__(self, url):
        self._url = url
        self._session = None

    def _build_url(self, url):
        return self._url + url

    def login(self, username, password):
        self._s = requests.Session()
        self._s.headers.update({'content-type': 'application/json'})
        self._s.get(self._build_url('/login'), auth=HTTPBasicAuth(username, password))
        print(self._s.cookies)

    def logout(self):
        self._s = None

    def register(self, username, password, email, firstName, lastName):
        self._s = requests.Session()
        self._s.headers.update({'content-type': 'application/json'})

        data = {
            'username': username,
            'password': password,
            'email': email,
            'firstName': firstName,
            'lastName': lastName
        }
        return self._s.post(self._build_url('/register'), data=json.dumps(data))

    def get_tags(self):
        # dynamic tag pulling removed because of detected issues in /tags - duplicated elements
        # res = requests.get(self._build_url('/tags'))
        # if res.status_code != 200 or res.json()['err']:
        #     raise Exception(f"Failed to get tags: {res} {res.json().get('err')}")
        # return res.json()['tags']
        res = '{"tags":["brown","geek","formal","blue","skin","red","action","sport","black","magic","green"],"err":null}'
        return json.loads(res)['tags']
        

    def get_catalogue(self, tags=[]):
        params = {
            'tags': ','.join(tags),
            'page': 1,
            'size': 100
        }
        res = requests.get(self._build_url('/catalogue'), params=params)
        if res.status_code != 200:
            raise Exception(f"Failed to get catalogue: {res} {res.json()}")

        return res.json()

    def get_cart(self):
        res = self._s.get(self._build_url('/cart'))
        if res.status_code != 200:
            raise Exception(f"failed to get cart: {res} {res.json()}")

        return res.json()

    def empty_cart(self, cart=None):
        if not cart:
            cart = self.get_cart()
        for item in cart:
            self.remove_from_cart(item['itemId'])

    def add_to_cart(self, item):
        data = {
            'id': item
        }

        res = self._s.post(self._build_url('/cart'), data=json.dumps(data))
        if res.status_code != 201:
            raise Exception(f"Failed to add {item} to cart: {res} {res.json()}")
        return res

    def remove_from_cart(self, item):
        res = self._s.delete(self._build_url(f'/cart/{item}'))
        if res.status_code != 202:
            raise Exception(f"Failed to remove {item} from cart: {res} {res.json()}")

        return res

    def checkout(self):
        res = self._s.post(self._build_url('/orders'))
        return
        if res.status_code != 201:
            raise Exception(f"Failed to checkout: {res} {res.json()}")

    def add_address(self, street, number, city, postcode, country):
        data = {
            "street": street,
            "number": number,
            "city": city,
            "postcode": postcode,
            "country": country
        }
        res = self._s.post(self._build_url('/addresses'), data=json.dumps(data))
        if res.status_code != 200:
            raise Exception(f"Failed to add address: {res} {res.json()}")
        return res.json()

    def get_address(self):
        res = self._s.get(self._build_url('/address'))
        if res.status_code != 200:
            raise Exception(f"Failed to get address: {res} {res.json()}")
        if res.json().get('status_code') == 500:
            return {}
        return res.json()

    def get_card(self):
        res = self._s.get(self._build_url('/card'))
        if res.status_code != 200:
            raise Exception(f"Failed to get card: {res} {res.json()}")
        if res.json().get('status_code') == 500:
            return {}
        return res.json()

    def get_orders(self):
        res = self._s.get(self._build_url('/orders'))
        if res.status_code != 201:
            raise Exception(f"Failed to get orders: {res} {res.json()}")
        return res.json()

    def add_credit_card(self, longnum, expires, ccv):
        data = {
            "longNum": longnum,
            "expires": expires,
            "ccv": ccv,
        }
        res = self._s.post(self._build_url('/cards'), data=json.dumps(data))
        if res.status_code != 200:
            raise Exception(f"Failed to add credit card: {res} {res.json()}")
        return res.json()

    def browse_to_item(self, id):
        res = self._s.get(self._build_url(f'/detail.html?id={id}'))
        if res.status_code not in [304, 200]:
            raise Exception(f"failed to browse to item {id}: {res} ")
