record WebSocket.Config {
  onOpen : Function(WebSocket, Promise(Never, Void)),
  onMessage : Function(String, Promise(Never, Void)),
  onError : Function(Promise(Never, Void)),
  onClose : Function(Promise(Never, Void)),
  reconnect : Bool,
  url : String
}

/* This module provides a wrapper over the WebSocket Web API. */
module WebSocket {
  /*
  Creates a websocket connection from the given configuration:

    websocket =
      WebSocket.open({
        url = "wss://echo.websocket.org",
        onMessage = handleMessage,
        onError = handleError,
        onClose = handleClose,
        onOpen = handleOpen,
        reconnect = true
      })

  If `reconnect` is set then when a connection is closed it tries to reconnect,
  using the same configuration (basically calls open again).
  */
  fun open (config : WebSocket.Config) : WebSocket {
    `
    (() => {
      /* Initialize a new WebSocket object. */
      const socket = new WebSocket(#{config.url})

      /* Event handlers. */
      const onMessage = (event) => #{config.onMessage(`event.data`)}
      const onError = () => #{config.onError()}
      const onOpen = () => #{config.onOpen(`socket`)}

      /*
      *  The close event handler is different:
      *  - removes event listeners
      *  - reconnects as a new websocket connection if specified
      *  - calls close event handler
      */
      const onClose = () => {
        socket.removeEventListener("message", onMessage);
        socket.removeEventListener("error", onError);
        socket.removeEventListener("close", onClose);
        socket.removeEventListener("open", onOpen);

        #{config.onClose()}

        if (#{config.reconnect} && !socket.shouldNotReconnect) {
          #{open(config)}
        }
      }

      /* Add event listeners. */
      socket.addEventListener("message", onMessage)
      socket.addEventListener("error", onMrror)
      socket.addEventListener("close", onMlose)
      socket.addEventListener("open", onMpen)

      return socket
    })()
    `
  }

  /*
  Sends the given data to the given websocket connection.

    WebSocket.send("some data", webscoket)
  */
  fun send (data : String, socket : WebSocket) : Promise(Never, Void) {
    `#{socket}.send(#{data})`
  }

  /*
  Closes the given given websocket connection.

    WebSocket.close(webscoket, true)

  If the `reconnect` flag was specified then the connection will reconnect using
  this function.
  */
  fun close (socket : WebSocket) : Promise(Never, Void) {
    `#{socket}.close()`
  }

  /*
  Closes the given given websocket connection without reconnecting, even if the
  `reconnect` flag was set.

    WebSocket.close(webscoket, true)
  */
  fun closeWithoutReconnecting (socket : WebSocket) : Promise(Never, Void) {
    `
    (() => {
      #{socket}.shouldNotReconnect = true;
      #{socket}.close();
    })()
    `
  }
}
