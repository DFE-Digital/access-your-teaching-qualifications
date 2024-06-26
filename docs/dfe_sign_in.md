# DfE Sign In

The Check service and Support Interface use DfE Sign In (DSI) for user authentication/authorisation.

Sign in flow includes a policy/role based authorisation step to ensure the DSI user has the required permissions to access the service or support interface. In this step the user can select from the organisations they belong to, in order to gain access to the appropriate part of the service.

## Configuring DSI callback action via DSI Manage

The Check and Support parts of the service both contain an `OmniAuthCallbacksController` which handles the response from DSI for a given authentication attempt.
The action or actions within this controller need routes which correspond to one of the **Redirect URL** values in DSI Manage.

eg. (where `dfe` is the action name in `OmniAuthCallbacksController`)

```
get "/auth/dfe/callback", to: "omniauth_callbacks#dfe"
```

## Configuring roles for Check and Support

DSI manages various organisations, policies and roles. These are assigned to users for authorisation purposes.
The DSI team is responsible for setup of this authorisation data.

The [`auth`](https://github.com/DFE-Digital/access-your-teaching-qualifications/blob/b670911dff04bb857680260ce8ec9e63bec5ab4f/app/controllers/check_records/omniauth_callbacks_controller.rb#L25) object we get back from successful authentication contains information about the user's roles for their organisations.
The application then checks for the appropriate role in a subsequent [DSI API call](https://github.com/DFE-Digital/login.dfe.public-api#get-user-access-to-service).

When giving users access to Check, you'll need to add them to an organisation type that has access to the service (see Policies in DSI Manage) and give them one of the roles that is enabled.

Check roles are stored in the database and managed via the Support console. When a user signs in, they will need at least one of their role codes to match an enabled role in the Check database.

## Configuring sign out from DSI

It is advisable to sign an authenticated user out of DSI as well as the service where appropriate. This allows the user to re-enter the authentication and authorisation flow and, if necessary, select a different organisation for authorisation.

Configuring the sign-out flow requires configuration in the application and in DSI Manage for the appropriate environment.

The application requires a route which corresponds to the DSI sign out URL. This URL can be configured in `config/intializers/omniauth.rb` via the `end_session_endpoint` client option. Otherwise the default value of `/auth/<callback action name>/sign-out` will be expected.

eg. (where `dfe` is the action name in `OmniAuthCallbacksController`)

```
get "/auth/dfe/sign-out", to: "sign_out#new", as: :dsi_sign_out
```

It is important to include the `id_token_hint` parameter with the [value from `auth.credentials.id_token`](https://github.com/DFE-Digital/access-your-teaching-qualifications/blob/56c30c2f7cda396b0da5004c2659be1ba09ca241/app/controllers/check_records/omniauth_callbacks_controller.rb#L20) when calling this route. This ensures that DSI knows which session it needs to invalidate.

We use a [custom OmniAuth strategy](https://github.com/DFE-Digital/access-your-teaching-qualifications/blob/56c30c2f7cda396b0da5004c2659be1ba09ca241/lib/omniauth/strategies/dfe_openid_connect.rb) to ensure that required request parameters are included in the redirect URL, the default strategy in `omniauth_openid_connect` does not currently support the `id_token_hint` parameter which is necessary for DSI to invalidate the user's session. Support of this method of session invalidation is optional according to the omniauth spec, DSI uses a provider implementation which relies on it. Hence the need for a custom strategy.

In the application, `config/initializers/omniauth.rb` should also be configured with a `post_logout_redirect_uri` value which corresponds to a **Logout redirect URL** value in DSI Manage. This is a requirement for DSI to safely redirect the user back to the application once their DSI session has been invalidated.

## Development

By default, a bypass mode for DSI is enabled in development (via the BYPASS_DSI environment variable). To test the actual auth flow locally, do the following:

1. Ensure you've been added to the service via the Manage console on the DSI dev environment (https://dev-manage.signin.education.gov.uk/). Speak to a colleague if you don't have access. You'll need to be added to an organisation of the correct type, and be assigned a valid role. See the Policies section in Manage for an idea of which types and roles have access to Check.
2. You'll also need to be added as an internal user to the Teaching Qualifications organisation for access to the AYTQ/CTR Support console.
3. Update your .env.development.local file such that `DFE_SIGN_IN_API_ROLE_CODES` is set with the role code you've been assigned in step 1.
4. Set `DFE_SIGN_IN_API_INTERNAL_USER_ROLE_CODE` to the internal user role code assigned in step 2.
5. Run `rake db:seed_role_codes`. This will copy the env var values into the database, matching how roles are set up in production.
6. Obtain the secret for the Check service from the Manage console.
7. Set `DFE_SIGN_IN_SECRET` to this value in your .env.development.local file.
8. Set `BYPASS_DSI` to false in your .env.development.local file.
9. Navigate to the Check sign in page and click "Sign in". Use http://check.localhost:3000 to ensure redirects works as expected.
10. Go through the DSI sign in process, after which you'll be redirected back to your locally running instance of the Check service.
