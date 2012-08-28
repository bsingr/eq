require 'benchmark'
require 'tmpdir'
require File.join(File.dirname(__FILE__), '..', 'lib', 'eq', 'boot', 'all')

EQ.logger.level = Logger::Severity::ERROR

class QueueBackendBenchmark < Struct.new(:executor)
  def run
    Benchmark.bm(50) do |benchmark|
      executor.benchmark = benchmark

      executor.report 'sequel with sqlite3 (in-memory)' do |config|
        config.queue = 'sequel'
      end

      executor.report 'sequel with sqlite3 (file)' do |config|
        config.queue = 'sequel'
        config.sequel = "sqlite://#{Dir.mktmpdir}/benchmark.sqlite3"
      end

      executor.report 'leveldb' do |config|
        config.queue = 'leveldb'
        config.leveldb = Dir.mktmpdir
      end
    end
  end
end
