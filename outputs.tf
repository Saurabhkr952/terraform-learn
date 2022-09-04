output "server-ip" {
    value = module.myapp-webserver.instance.public_ip
}