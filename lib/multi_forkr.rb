class MultiForkr

  # The PID of the Forkr master
  # @return [Fixnum]
  attr_reader :master_pid

  # Child Process Definitions
  # @return Hash<Object, Integer>
  attr_reader :child_defs
 
  # Child process pids.
  # @return Hash<Object, [Pids]>
  attr_reader :child_sets

  # @param forklets Hash<Object, Integer> the worker objects, with counts
  def initialize(forklets)
    @child_defs = forklets
    @master_pid = $$
    @child_sets = Hash.new { |h, k| h[k] = Array.new }
    @in_shutdown = false
  end

  # Start the master, and spawn workers
  # @return [nil]
  def run
    @inbound, @outbound = IO.pipe
    Signal.trap('CHLD') { dead_child }
    Signal.trap('INT') { interrupt }
    Signal.trap('TERM') { shutdown }
    Signal.trap('QUIT') { core_dump_quit }
    master_loop
  end

  protected

  attr_reader :inbound, :outbound

  def send_wake_notice(notice)
    return(nil) if $$ != master_pid
    return(nil) if @in_shutdown
    @outbound.write(notice)
  end

  def core_dump_quit
    send_wake_notice("Q")
  end

  def interrupt
    send_wake_notice("I")
  end

  def shutdown
    send_wake_notice("T")
  end

  def dead_child
    send_wake_notice("D")
  end

  def spawn_worker(forklet)
    if new_pid = fork
      existing_worker_pids = @child_sets[forklet]
      @child_sets[forklet] = existing_worker_pids + [new_pid]
    else
      worker_loop(forklet)
    end
  end

  def shutdown_using(sig)
    @in_shutdown = true
    signal_all_workers(sig)
    raise StopIteration.new
  end

  def master_loop
    catch(:bail_because_im_a_worker) do
      ensure_right_worker_count
      loop do
        fds = IO.select([@inbound],nil,nil,2)
        unless fds.nil?
          data_read = fds.first.first.read(1)
          if data_read == "I"
            shutdown_using(:INT)
          elsif data_read == "T"
            shutdown_using(:TERM)
          elsif data_read == "Q"
            shutdown_using(:QUIT)
          end
        end
        prune_workers
        ensure_right_worker_count
      end
      reap_all_workers
      @outbound.close
      @inbound.close
    end
  end

  def reap_all_workers
    begin
      wpid, status = Process.waitpid2(-1, Process::WNOHANG)
    rescue Errno::ECHILD
      break
    end while true
  end

  def ensure_right_worker_count
    @child_defs.each_pair do |k, v|
      existing_workers = @child_sets[k]
      off_by = v - existing_workers.length
      if off_by > 0
        off_by.times do
          spawn_worker(k)
        end
      elsif off_by < 0
        existing_workers.take(off_by.abs).each do |kid|
          signal_worker(kid, :TERM)
        end
      end
    end
  end

  def children
    @child_sets.values.map { |v| v }
  end

  def signal_all_workers(sig)
    children.each { |c| signal_worker(c, sig) }
  end

  def signal_worker(wpid, signal)
    begin
      Process.kill(signal, wpid)
    rescue Errno::ESRCH
    end
  end

  def prune_workers
    new_sets = {}
    @child_sets.each_pair do |k, v|
      living_children = v.reject { |pid| child_dead?(pid) }
      new_sets[k] = living_children
    end
    @child_sets = new_sets
  end

  def worker_loop(forklet)
    forklet.after_fork if forklet.respond_to?(:after_fork)
    @inbound.close
    @outbound.close
    $stderr.puts "Worker spawned as #{$$}!"
    forklet.run
    throw(:bail_because_im_a_worker)
  end

  def child_dead?(pid)
    status = Process.waitpid(pid, Process::WNOHANG)
    unless status.nil?
      $stderr.puts "Process #{pid} dead: #{status}"
    end
    !status.nil?
  end
end
