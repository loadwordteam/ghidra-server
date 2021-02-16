# Non-trivial Ghidra Server Container
My attempt to confine Ghidra server in a container for serious work
and not just as once in a time deployment. There are various reasons
why you want to start a small project on reverse engineering, our
software legacy spans decades and it's not unusual the need to
understand and modify a piece of machine code when the source is lost
or not available.

Ghidra has a nice feature for collaboration but needs a server
somewhere, the software it's a bit rough in my opinion but good
enough, needs a bit of care and patient to learn all the
quirks. Unfortunately doesn't play nice with RedHat based system,
that's why I wrote this Docekrfile.

## Getting Started
Read the files and the comments in the source code, this image is
useful especially if you want to deploy on a Fedora/Centos/RedHat
based system.

### Prerequisites
In order to run this container you'll need Docker installed but should
work just fine on podman, beware this server expect to run with root
privileges!


### Usage
Read the files in this repository, it's not hard to setup this service!

#### Environment Variables

Check the the `.env.example` file, you need a few things before
launching the service.

* `GHIDRA_CERT_PATH` A path you might want to mount as a volume for
  storing the SSL certificates
* `GHIDRA_CERT_PASSWORD` The password to unlock the certificate.

#### Volumes

* `/srv/repositories` - This directory holds your data when you work
  in ghidra, it's a good idea to backup it up.

## Authors

* **Gianluigi "Infrid" Cusimano** - *Initial work* and artist of
  making simple concept utterly complex.

## License

This project is licensed under the MIT License - see the
[LICENSE](LICENSE) file for details.

## Acknowledgements

Thanks to [Giovanni "gionniboy" Pullara](https://github.com/gionniboy)
and Filippo "joeyrs" Civiletti for the patience and kindness in
answering all my questions and point me in the right direction.
