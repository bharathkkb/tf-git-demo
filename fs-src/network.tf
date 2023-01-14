module "dev-base" {
  source  = "terraform-google-modules/network/google"
  version = "~> 5.0"

  project_id   = module.vpc-host-dev.project_id
  network_name = "dev-base"

  subnets = [

    {
      subnet_name               = "sb-dev-shared-base-1"
      subnet_ip                 = "192.192.0.0/24"
      subnet_region             = "us-central1"
      subnet_private_access     = true
      subnet_flow_logs          = true
      subnet_flow_logs_sampling = "0.5"
      subnet_flow_logs_metadata = "INCLUDE_ALL_METADATA"
      subnet_flow_logs_interval = "INTERVAL_10_MIN"
    },
    {
      subnet_name               = "sb-dev-shared-base-2"
      subnet_ip                 = "192.192.128.0/24"
      subnet_region             = "europe-west1"
      subnet_private_access     = true
      subnet_flow_logs          = true
      subnet_flow_logs_sampling = "0.5"
      subnet_flow_logs_metadata = "INCLUDE_ALL_METADATA"
      subnet_flow_logs_interval = "INTERVAL_10_MIN"
    },
  ]
  firewall_rules = [
    {
      name      = "dev-base-allow-iap-rdp"
      direction = "INGRESS"
      priority  = 10000
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
      allow = [{
        protocol = "tcp"
        ports    = ["3389"]
      }]
      ranges = [
        "35.235.240.0/20",
      ]
    },
    {
      name      = "dev-base-allow-iap-ssh"
      direction = "INGRESS"
      priority  = 10000
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
      allow = [{
        protocol = "tcp"
        ports    = ["22"]
      }]
      ranges = [
        "35.235.240.0/20",
      ]
    },
    {
      name      = "dev-base-allow-icmp"
      direction = "INGRESS"
      priority  = 10000
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
      allow = [{
        protocol = "icmp"
        ports    = null
      }]
      ranges = [
        "10.128.0.0/9",
      ]
    }
  ]
}
