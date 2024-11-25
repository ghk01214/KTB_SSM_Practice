module "network" {
    source = "./module/network"
}

module "node" {
    source            = "./module/node"

    private_subnet_id = module.network.private_subnet_id
    security_group_id = module.network.security_group_id
}

module "load_balancer" {
    source            = "./module/load_balancer"

    vpc_id            = module.network.vpc_id
    public_subnet_ids = module.network.public_subnet_ids
    security_group_id = module.network.security_group_id
    node_id           = module.node.node_id
}