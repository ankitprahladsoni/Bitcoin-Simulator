defmodule Utils do
  # def via_tuple(node_id), do: {:via, Registry, {:registry, node_id}}

  # def getPid(node_id) do
  #   case Registry.lookup(:registry, node_id) do
  #     [{pid, _}] -> pid
  #     [] -> nil
  #   end
  # end

  # def alive?(id) do
  #   getPid(id) != nil
  # end

  # def notAlive?(id) do
  #   if(getPid(id) == nil) do
  #     IO.puts("checking not alive for #{id}")
  #   end

  #   getPid(id) == nil
  # end

  def notNil?(value), do: value != nil

  # def nil?(value), do: value == nil
end
