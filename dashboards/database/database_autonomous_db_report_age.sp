dashboard "oci_database_autonomous_database_age_report" {

  title         = "OCI Database Autonomous DB Age Report"
  documentation = file("./dashboards/database/docs/database_autonomous_db_report_age.md")

  tags = merge(local.database_common_tags, {
    type     = "Report"
    category = "Age"
  })

  container {

    card {
      sql   = query.oci_database_autonomous_db_count.sql
      width = 2
    }

    card {
      sql   = query.oci_database_autonomous_db_24_hrs.sql
      width = 2
      type  = "info"
    }

    card {
      sql   = query.oci_database_autonomous_db_30_days.sql
      width = 2
      type  = "info"
    }

    card {
      sql   = query.oci_database_autonomous_db_90_days.sql
      width = 2
      type  = "info"
    }

    card {
      sql   = query.oci_database_autonomous_db_365_days.sql
      width = 2
      type  = "info"
    }

    card {
      sql   = query.oci_database_autonomous_db_1_year.sql
      width = 2
      type  = "info"
    }

  }

  table {
    column "OCID" {
      display = "none"
    }

    sql = query.oci_database_autonomous_db_age_report.sql
  }

}

query "oci_database_autonomous_db_24_hrs" {
  sql = <<-EOQ
    select
      count(*) as value,
      '< 24 hours' as label
    from
      oci_database_autonomous_database
    where
      lifecycle_state <> 'TERMINATED' and time_created > now() - '1 days' :: interval;
  EOQ
}

query "oci_database_autonomous_db_30_days" {
  sql = <<-EOQ
    select
      count(*) as value,
      '1-30 Days' as label
    from
      oci_database_autonomous_database
    where
      lifecycle_state <> 'TERMINATED' and time_created between symmetric now() - '1 days' :: interval and now() - '30 days' :: interval;
  EOQ
}

query "oci_database_autonomous_db_90_days" {
  sql = <<-EOQ
    select
      count(*) as value,
      '30-90 Days' as label
    from
      oci_database_autonomous_database
    where
      lifecycle_state <> 'TERMINATED' and time_created between symmetric now() - '30 days' :: interval and now() - '90 days' :: interval;
  EOQ
}

query "oci_database_autonomous_db_365_days" {
  sql = <<-EOQ
    select
      count(*) as value,
      '90-365 Days' as label
    from
      oci_database_autonomous_database
    where
      lifecycle_state <> 'TERMINATED' and time_created between symmetric (now() - '90 days'::interval) and (now() - '365 days'::interval);
  EOQ
}

query "oci_database_autonomous_db_1_year" {
  sql = <<-EOQ
    select
      count(*) as value,
      '> 1 Year' as label
    from
      oci_database_autonomous_database
    where
      lifecycle_state <> 'TERMINATED' and time_created <= now() - '1 year' :: interval;
  EOQ
}

query "oci_database_autonomous_db_age_report" {
  sql = <<-EOQ
    select
      d.display_name as "Name",
      now()::date - d.time_created::date as "Age in Days",
      d.time_created as "Create Time",
      d.lifecycle_state as "Lifecycle State",
      t.title as "Tenancy",
      coalesce(c.title, 'root') as "Compartment",
      d.region as "Region",
      d.id as "OCID"
    from
      oci_database_autonomous_database as d
      left join oci_identity_compartment as c on d.compartment_id = c.id
      left join oci_identity_tenancy as t on d.tenant_id = t.id
    where
      d.lifecycle_state <> 'TERMINATED'
    order by
      d.display_name;
  EOQ
}