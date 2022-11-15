job "osticket_backup" {
    
    type = "batch"

    periodic {
      cron = "@daily"
    }
    
    reschedule {
      attempts  = 0
      unlimited = false
    }

    datacenters = ["MyDatacenter"]
    
    group "osticket-backup" {

        volume "osticket_db" {
            type      = "host"
            read_only = false
            source    = "osticket_db"
        }

        volume "borg_config" {
            type      = "host"
            read_only = false
            source    = "borg_config"
        }

        volume "borg_repo" {
            type      = "host"
            read_only = false
            source    = "borg_repo"
        }

        task "osticket-backup-db" {
            driver = "docker"
            user = "root"

            config {
                image = "pschiffe/borg"
                force_pull = false
            }

            volume_mount {
                volume      = "osticket_db"
                destination = "/data" #<-- in the container
                read_only   = false
            }

            volume_mount {
                volume      = "borg_config"
                destination = "/root" #<-- in the container
                read_only   = false
            }

            volume_mount {
                volume      = "borg_repo"
                destination = "/opt/borg" #<-- in the container
                read_only   = false
            }

            env {
                BORG_REPO="/opt/borg"
                BORG_PASSPHRASE="mypassword"
                BACKUP_DIRS="/data"
                ARCHIVE="${NOMAD_SHORT_ALLOC_ID}"
                COMPRESSION="lz4"
                PRUNE=1
                KEEP_DAILY=7
                KEEP_WEEKLY=1
                KEEP_MONTHLY=1
            }
        }
    }
} 
