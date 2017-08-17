ExUnit.start()

{:ok, files} = File.ls("./test/helpers")

Enum.each files, fn(file) ->
  Code.require_file "helpers/#{file}", __DIR__
end
