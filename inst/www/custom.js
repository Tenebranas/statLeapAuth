// custom.js
fetch('/config.json')
  .then(response => response.json())
  .then(config => {
    window.addEventListener('message', function(event) {
      if (!config.trustedOrigins.includes(event.origin)) {
        console.warn('Untrusted origin:', event.origin);
        return;
      }

      const sessionId = event.data.sessionId;
      const userId = event.data.userId;

      if (sessionId && userId) {
        console.log('Received session ID:', sessionId);
        console.log('Received user ID:', userId);

        // Update Shiny inputs with sessionId and userId
        Shiny.onInputChange('session_id', sessionId);
        Shiny.onInputChange('user_id', userId);

        // Send a response back to the sender
        event.source.postMessage({
          status: 'success',
          message: 'Session ID and User ID received successfully',
          receivedSessionId: sessionId,
          receivedUserId: userId
        }, event.origin);
        
      } else {
        console.warn('No session ID or user ID provided');

        // Send a response indicating failure
        event.source.postMessage({
          status: 'error',
          message: 'Session ID or User ID missing'
        }, event.origin);
      }
    });
  })
  .catch(error => console.error('Error loading config:', error));
