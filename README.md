# Tang Docker Container on Alpine

## Authors

Original work by [Michel Belleau](https://github.com/malaiwah), which was forked from Nathaniel McCallum's repo,
which in turn was taken from [Adrian Lucrèce Céleste](https://github.com/AdrianKoshka)

Bashed into shape to make it build with Alpine 3:13 by Dave Baker <dbaker@redhat.com>, to later be updated to base on UBI.


## Usage

Look at kube.yaml for an example of kubernetes deployment.


echo "Hello World..." | clevis encrypt tang '{ "url": "http://tang.example.com/" }' > secret.jwe

clevis decrypt < secret.jwe


Note: no tidy up of old jwk files is done at this time

