require 'rbatch'

# Config
p RBatch.config["key1"]
p RBatch.config["key2"]

# cmd
result = RBatch.cmd("ls")
p result.stdout
p result.stderr
p result.status
p result

# Log
RBatch::Log.new{|log|
  log.info("hello world")
  log.error("this is error")
  raise "Exception here"
}

