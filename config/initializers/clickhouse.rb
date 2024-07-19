require 'clickhouse-activerecord'

ActiveRecord::Base.establish_connection(
    adapter: 'clickhouse',
    database: 'aws_billing',
    host: 'localhost',
    port: 8123
)
