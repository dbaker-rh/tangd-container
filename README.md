# Tang Docker Container on Alpine

## Authors

Original work by [Michel Belleau](https://github.com/malaiwah), which was forked from Nathaniel McCallum's repo,
which in turn was taken from [Adrian Lucrèce Céleste](https://github.com/AdrianKoshka)

Bashed into shape to make it build with Alpine 3.13 by Dave Baker <dbaker@redhat.com> to work on a general
kubernetes cluster, alternatively building against Alpine 3.8 (for Raspberry Pi Zero / Zero W).


## Notes

These alpine images are tiny (approx 6MB), far smaller than an equivalent UBI
based image, and although unsupported are well suited to a small development
lab, e.g. one that uses rPi.

For production use, you should "dnf install tang" on RHEL or UBI.


## Multiarch notes

I've not had luck with "buildx", nor pushing multiarch images to quay.io
but it works fine on docker hub.  To be debugged at a later stage.

For x86:
  make build

For arm, run locally on a raspberry pi
  docker build ....

REPOUSER=dbakerrh
VER=3.19

podman pull docker.io/$REPOUSER/tangd:${VER}-amd64
podman pull docker.io/$REPOUSER/tangd:${VER}-armhf

podman rmi docker.io/$REPOUSER/tangd:$VER

podman manifest create docker.io/$REPOUSER/tangd:$VER \
       --amend docker.io/$REPOUSER/tangd:${VER}-amd64 \
       --amend docker.io/$REPOUSER/tangd:${VER}-armhf

podman manifest push docker.io/$REPOUSER/tangd:$VER




## Usage Examples

### Kubernetes

Look at kube.yaml for an example of kubernetes deployment.


### Decrypting JWE

clevis decrypt < secret.jwe

or

cat secret.jwe | clevis decrypt


### Decrypting clevis header from disk

Assuming token #0 from the first/only LUKS crypted disk:

````
cryptsetup token export $( blkid -t TYPE=crypto_LUKS -o device | head -1 ) --token-id 0
````

To decrypt that JSON object, use this, which also reformats into four character blocks to make it easier to manually type in:

````
echo $savedtoken | jq -r '[.jwe.protected, .jwe.encrypted_key, .jwe.iv, .jwe.ciphertext, .jwe.tag] | join(".")' | clevis decrypt | sed 's/.\{4\}/& /g'; echo
````


### Encrypting against Single Tang server

Interative confirmation of thumbprint:

````
date | clevis encrypt tang '{ "url": "http://tang.example.com/" }' > secret.jwe
````


Automatic:

````
date | clevis encrypt tang '{ "url: "http://tang.example.com/", "thp": "CCgrFcM1b59GO6GcJPQHaeKAY0M" }' > secret.jwe
````




### Encrypting against Multiple Tang servers

Within "clevis luks ...", you can create multiple binds, one for each tang server.  Or, shard the key across multiple
tang servers such that "t=1" any one of these servers needs to respond to recreate the original material.  A variation
on this of course is "t=2" where any two of the three servers needs to respond.

This uses "sss", which in turn references the multiple tang servers.  The "thp" thumbprint can also be declared here.

```
date | clevis encrypt sss '
  {
    "t": 1,
    "pins": {
      "tang": [
        {
          "url": "http://tang1.example.com",
          "thp": "CCgrFcM1b59GO6GcJPQHaeKAY0M"
        },
        {
          "url": "http://tang2.example.com",
          "thp": "D9juScp-WiGaM4m7TL8ep2JPx-4"
        },
        {
          "url": "http://tang3.example.com",
          "thp": "_aQPuLvOGPUTM_QGSiqLgl15p4Y"
        }
      ]
    }
  }
'
```




### Encrypting against Multiple Tang servers and TPM

Configuration:

```
{
  "t": 2,
  "pins": {
    "sss": {
      "t": 1,
      "pins": {
        "tang": [
          {
            "url": "http://tang1.example.com",
            "thp": "CCgrFcM1b59GO6GcJPQHaeKAY0M"
          },
          {
            "url": "http://tang2.example.com",
            "thp": "D9juScp-WiGaM4m7TL8ep2JPx-4"
          },
          {
            "url": "http://tang3.example.com",
            "thp": "_aQPuLvOGPUTM_QGSiqLgl15p4Y"
          }
        ]
      }
    },
    "tpm2": {}
  }
}
```
