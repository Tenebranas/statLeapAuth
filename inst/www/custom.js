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

        Shiny.onInputChange('session_id', sessionId);
        Shiny.onInputChange('user_id', userId);
      } else {
        console.warn('No session ID or user ID provided');
      }
    });
  })
  .catch(error => console.error('Error loading config:', error));
