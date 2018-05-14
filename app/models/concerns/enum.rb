module Concerns
  module Enum
    extend ActiveSupport::Concern

    LoadBalance = {
      RoundRobin: 0, IPHash: 1
    }.freeze

    def key_of_lb(v)
      LoadBalance.key(v.to_i)
    end

    CircuitStatus = {
      Open: 0,
      Half: 1,
      Close: 2
    }.freeze

    def key_of_cs(v)
      CircuitStatus.key(v.to_i)
    end

    Protocol = {
      HTTP:   0,
      Grpc:   1,
      Dubbo:  2,
      SpringCloud: 3
    }

    def key_of_pt(v)
      Protocol.key(v.to_i)
    end

    Status = {
      Down: 0,
      Up: 1,
      Unknown: 2
    }

    def key_of_status(v)
      Status.key(v.to_i)
    end

    Strategy = {
      Copy: 0,
      Split: 1
    }

    def key_of_rs(v)
      Strategy.key(v.to_i)
    end
  end
end
