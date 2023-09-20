# DfE Sign In

The Check service uses DfE Sign In (DSI) for user authentication/authorization.

## Development

By default, a bypass mode for DSI is enabled in development (via the BYPASS_DSI environment variable). To test the actual auth flow locally, do the following:

1. Ensure you've been added to the service via the Manage console on the DSI dev environment (https://dev-manage.signin.education.gov.uk/). Speak to a colleague if you don't have access.
2. Obtain the secret for the Check service from the Manage console.
3. Set DFE_SIGN_IN_SECRET to this value in your .env.development.local file.
4. Set BYPASS_DSI to false in your .env.development.local file.
5. Navigate to the Check sign in page and click "Sign in". Use http://check.localhost:3000 to ensure redirects works as expected.
6. Go through the DSI sign in process, after which you'll be redirected back to your locally running instance of the Check service.
