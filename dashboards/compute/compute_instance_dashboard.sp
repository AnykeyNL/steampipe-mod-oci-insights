dashboard "compute_instance_dashboard" {

  title         = "OCI Compute Instance Dashboard"
  documentation = file("./dashboards/compute/docs/compute_instance_dashboard.md")

  tags = merge(local.compute_common_tags, {
    type = "Dashboard"
  })

  container {

    card {
      query = query.compute_instance_count
      width = 3
    }

    card {
      query = query.compute_instance_total_cores
      width = 3
    }

  }






# Card Queries

query "compute_instance_count" {
  sql = <<-EOQ
    select count(*) as "Instances" from oci_core_instance where lifecycle_state <> 'TERMINATED';
  EOQ
}

query "compute_instance_total_cores" {
  sql = <<-EOQ
    select
      sum(shape_config_ocpus)  as "Total OCPUs"
    from
      oci_core_instance
    where
      lifecycle_state <> 'TERMINATED';
  EOQ
}

