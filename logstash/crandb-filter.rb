
def paste(x)
  out = ""
  if x === nil then
    return out
  end
  x.each do |key, value|
    out = out + key.to_s + " (" + value.to_s + "), "
  end
  return out
end

# the filter method receives an event and must return a list of events.
# Dropping an event means not including it in the return array,
# while creating new ones only requires you to add a new instance of
# LogStash::Event to the returned array
def filter(event)
  doc = event.get("doc")

  # null object?
  if (!doc) then
    return []
  end

  # not a package?
  if (doc["type"] and doc["type"] != "package") then
    return []
  end

  # skip archivals
  if (doc["archived"]) then
    return []
  end

  # Otherwise take the latest version, if exists (it always should)
  if (!doc["latest"]) then
    return []
  end

  # set revdeps, downloads
  latest = doc["versions"][ doc["latest"] ]
  latest["revdeps"] = doc["revdeps"] || 1
  latest["downloads"] = doc["downloads"] || 1

  # squash dependency fields
  latest["Imports"] = paste(latest["Imports"])
  latest["Depends"] = paste(latest["Depends"])
  latest["Suggests"] = paste(latest["Suggests"])
  latest["Enhances"] = paste(latest["Enhances"])
  latest["LinkingTo"] = paste(latest["LinkingTo"])

  latest.each do |key, value|
    event.set(key, value)
  end
  event.set("doc", nil)
  return [event]
end
