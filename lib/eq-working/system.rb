module EQ::Working
  class System < Celluloid::SupervisionGroup
    include EQ::Logging

    # TODO celluloid: replace this with the following in the next version
    # pool Worker, as: _eq_working_pool
    supervise EQ::Working::Worker, as: :_eq_working_pool, method: 'pool_link'
    supervise EQ::Working::Manager, as: :_eq_working_manager
  end
end
