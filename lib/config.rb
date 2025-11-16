require 'dvla/herodotus'

LOG = DVLA::Herodotus.logger('log-parser', output_path: "out/log#{Time.now.strftime('%Y-%m-%d_%H-%M-%S')}.txt")
