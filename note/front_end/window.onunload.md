### under chromium
  error message `Blocked alert/prompt/confirm() during beforeunload/unload.` would come up, when we call alert,prompt and confirm method of Window object in beforeunload or unload event handler.
  do request by ajax under beforeunload event handler rather than unload. because of request would be missed in unload event handler.

### under firefox
  there is no response even error, when we call alert,prompt and confirm method of Window object in beforeunload or unload event handler.
  it's ok to do request by ajax under beforeunload or unload.
