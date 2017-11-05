--
-- Function for catching errors and returning the traceback (AKA stack trace).
--
function catchError(err)
  if debug then
    return err..debug.traceback().."\n"
  end
end
