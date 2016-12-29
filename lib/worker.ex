defmodule Blitzy.Worker do
  def start(script, url) do
    apply(Blitzy.Scenarios, :"#{script}", [url])
  end
end
