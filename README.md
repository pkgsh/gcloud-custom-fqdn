# gcloud-custom-fqdn
This pakge will enable custom hostnames on Google Compute Engine

### Installation

```
install.sh pkgsh/gcloud-custom-fqdn
```
or

```
sh <(curl -sL http://install.opensource.sh/pkgsh/gcloud-custom-fqdn)
```

### Usage
To take advantage of this you should set metadata with name `fqdn` on your instance. You have to set it after the creation

This is the example of creation process:
```sh
gcloud compute instances create insance-name \
  --boot-disk-size 20GB \
  --boot-disk-type pd-ssd \
  --image centos-6 \
  --machine-type n1-standard-2 \
  --zone europe-west1-c \
  --metadata startup-script='sh <(curl -sL http://install.opensource.sh/pkgsh/gcloud-custom-fqdn)'
```

Add FQDN:

```sh
gcloud compute instances add-metadata insance-name --metadata fqdn='my.hostname.example.com'
```

### Contributing
Fork the [pkgsh/gcloud-custom-fqdn repo on GitHub](https://github.com/pkgsh/gcloud-custom-fqdn), make changes, fix bugs, add compatibilities or make something cool and after that just send a Pull Request. :)
