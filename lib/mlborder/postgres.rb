module Mlborder
  class Postgres
    attr_reader :cli

    def initialize
      require 'pg'
      @cli = PG::connect(
        host: RBatch.common_config["POSTGRES_HOST"],
        user: RBatch.common_config["POSTGRES_USER"],
        password: RBatch.common_config["POSTGRES_PASS"],
        dbname: RBatch.common_config["POSTGRES_DATABASE"],
        port: RBatch.common_config["POSTGRES_PORT"]
      )
    end
  end
end
